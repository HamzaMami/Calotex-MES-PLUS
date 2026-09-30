import { Router } from "express";
import { authenticate, AuthenticatedRequest } from "../../auth/middleware/auth.midlleware";
import pool from "../../../config/db";
import multer from "multer";
import { uploadFile } from "../../../shared/services/supabase-storage.service";

const router = Router();
router.use(authenticate);
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 2 * 1024 * 1024 } });

router.patch("/", upload.single("avatar"), async (req: AuthenticatedRequest, res) => {
  const id = req.user?.id;
  const name = typeof req.body.name === "string" ? req.body.name.trim() : "";
  const avatarFile = req.file;
  if (!id || !name) {
    return res.status(400).json({ status: "error", message: "A name is required" });
  }
  if (avatarFile && !avatarFile.mimetype.startsWith("image/")) {
    return res.status(400).json({ status: "error", message: "Profile picture must be an image" });
  }
  const avatar = avatarFile
    ? await uploadFile(avatarFile, `profiles/${id}`, "avatar")
    : req.body.avatar == null ? null : String(req.body.avatar);
  const result = await pool.query(
    `UPDATE users
        SET name = $2, avatar = $3, updated_at = NOW()
      WHERE id = $1
      RETURNING id, name, email, avatar, role_id, created_at`,
    [id, name, avatar],
  );
  if (!result.rowCount) {
    return res.status(404).json({ status: "error", message: "User not found" });
  }
  const roleResult = await pool.query(
    `SELECT r.name AS role
       FROM roles r
      WHERE r.id = $1`,
    [result.rows[0].role_id],
  );
  const updated = result.rows[0];
  res.json({
    status: "success",
    data: {
      id: updated.id,
      name: updated.name,
      email: updated.email,
      avatar: updated.avatar,
      role: roleResult.rows[0]?.role ?? "",
      created_at: updated.created_at,
    },
  });
});

export default router;
