import { createClient } from "@supabase/supabase-js";
import { env } from "../../config/env";
import pool from "../../config/db";

const configured = Boolean(env.supabase.url && env.supabase.serviceRoleKey);
const client = configured
  ? createClient(env.supabase.url, env.supabase.serviceRoleKey)
  : null;

export const uploadFile = async (
  file: Express.Multer.File,
  folder: string,
  name: string,
): Promise<string> => {
  if (!client) {
    throw new Error(
      "Supabase Storage is not configured. Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY.",
    );
  }

  const path = `${folder}/${name}`;
  const { error } = await client.storage.from(env.supabase.bucket).upload(path, file.buffer, {
    contentType: file.mimetype,
    upsert: true,
  });
  if (error) {
    throw new Error(`Supabase upload failed for ${name}: ${error.message}`);
  }

  const { data } = client.storage.from(env.supabase.bucket).getPublicUrl(path);
  return data.publicUrl;
};

export const uploadProductFile = (
  file: Express.Multer.File,
  productCode: string,
  field: "assembly_pdf" | "product_photo",
) => uploadFile(file, `products/${productCode}`, `${field}.${field === "assembly_pdf" ? "pdf" : "png"}`);

export const archiveUploadedFile = async (
  file: Express.Multer.File,
  kind: "export_plan_excel" | "productivity_excel",
  userId: number | null,
): Promise<string> => {
  const url = await uploadFile(
    file,
    `imports/${kind}`,
    `${Date.now()}-${file.originalname.replace(/[^a-zA-Z0-9._-]/g, "_")}`,
  );
  await pool.query(
    `INSERT INTO uploaded_files (kind, file_url, original_name, mime_type, uploaded_by)
     VALUES ($1, $2, $3, $4, $5)`,
    [kind, url, file.originalname, file.mimetype, userId],
  );
  return url;
};
