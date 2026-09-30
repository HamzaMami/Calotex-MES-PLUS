import { Request, Response } from "express";
import * as productService from "../services/product.service";
import { asyncHandler } from "../../../shared/utils/asyncHandler";
import { uploadProductFile } from "../../../shared/services/supabase-storage.service";

const addUploadedFiles = async (req: Request, productCode: string): Promise<Record<string, string>> => {
  const files = req.files as Record<string, Express.Multer.File[]> | undefined;
  const values: Record<string, string> = {};
  for (const [field, entries] of Object.entries(files ?? {})) {
    const file = entries[0];
    if (file) {
      values[field] = await uploadProductFile(
        file,
        productCode,
        field as "assembly_pdf" | "product_photo",
      );
    }
  }
  return values;
};

export const getAllProducts = asyncHandler(async (req: Request, res: Response) => {
  const page = req.query.page ? parseInt(req.query.page as string, 10) : undefined;
  const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : undefined;

  const products = await productService.getAllProducts(page, limit);
  res.status(200).json({ status: "success", data: products });
});

export const getProductById = asyncHandler(async (req: Request, res: Response) => {
  const id = parseInt(req.params.id as string, 10);
  const product = await productService.getProductById(id);
  if (!product) {
    return res.status(404).json({ status: "error", message: "Product not found" });
  }
  res.status(200).json({ status: "success", data: product });
});

export const createProduct = asyncHandler(async (req: Request, res: Response) => {
  const product = await productService.createProduct({
    ...req.body,
    ...await addUploadedFiles(req, req.body.product_code),
  });
  res.status(201).json({ status: "success", data: product });
});

export const updateProduct = asyncHandler(async (req: Request, res: Response) => {
  const id = parseInt(req.params.id as string, 10);
  const product = await productService.updateProduct(id, {
    ...req.body,
    ...await addUploadedFiles(req, req.body.product_code ?? `product-${id}`),
  });
  if (!product) {
    return res.status(404).json({ status: "error", message: "Product not found" });
  }
  res.status(200).json({ status: "success", data: product });
});

export const deleteProduct = asyncHandler(async (req: Request, res: Response) => {
  const id = parseInt(req.params.id as string, 10);
  const success = await productService.deleteProduct(id);
  if (!success) {
    return res.status(404).json({ status: "error", message: "Product not found" });
  }
  res.status(200).json({ status: "success", message: "Product deleted successfully" });
});
