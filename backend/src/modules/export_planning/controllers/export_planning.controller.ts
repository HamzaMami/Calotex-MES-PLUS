import { Request, Response } from "express";
import { asyncHandler } from "../../../shared/utils/asyncHandler";
import { AuthenticatedRequest } from "../../auth/middleware/auth.midlleware";
import * as service from "../services/export_planning.service";
import { archiveUploadedFile } from "../../../shared/services/supabase-storage.service";

const userId = (req: Request): number | null =>
  Number.isInteger((req as AuthenticatedRequest).user?.id)
    ? (req as AuthenticatedRequest).user!.id
    : null;

const idParam = (req: Request): number => {
  const raw = req.params.id;
  return Number.parseInt(Array.isArray(raw) ? raw[0] : raw, 10);
};

type FileRequest = Request & { file?: Express.Multer.File };

export const list = asyncHandler(async (req: Request, res: Response) => {
  const year = req.query.year == null ? undefined : Number(req.query.year);
  if (year !== undefined && (!Number.isInteger(year) || year < 2000 || year > 2100)) {
    return res.status(400).json({ status: "error", message: "Invalid year" });
  }
  res.status(200).json({ status: "success", data: await service.list(year) });
});

export const get = asyncHandler(async (req: Request, res: Response) => {
  const plan = await service.get(idParam(req));
  if (!plan) return res.status(404).json({ status: "error", message: "Export plan not found" });
  res.status(200).json({ status: "success", data: plan });
});

export const create = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
  res.status(201).json({ status: "success", data: await service.create(req.body, userId(req)) });
});

export const update = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
  const plan = await service.update(idParam(req), req.body, userId(req));
  if (!plan) return res.status(404).json({ status: "error", message: "Export plan not found" });
  res.status(200).json({ status: "success", data: plan });
});

export const remove = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
  const removed = await service.remove(idParam(req), userId(req));
  if (!removed) return res.status(404).json({ status: "error", message: "Export plan not found" });
  res.status(200).json({ status: "success", message: "Export plan deleted successfully" });
});

export const clearAll = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
  const year = Number(req.query.year);
  const week = Number(req.query.week);
  if (
    !Number.isInteger(year) || year < 2000 || year > 2100 ||
    !Number.isInteger(week) || week < 1 || week > 53
  ) {
    return res.status(400).json({ status: "error", message: "A valid year and week are required" });
  }
  await service.clearWeek(year, week, userId(req));
  res.status(200).json({ status: "success", message: `KW ${week} (${year}) cleared successfully` });
});

export const preview = asyncHandler(async (req: Request, res: Response) => {
  const file = (req as FileRequest).file;
  if (!file) return res.status(400).json({ status: "error", message: "An Excel file is required" });
  const plans = await service.preview(file.buffer);
  res.status(200).json({ status: "success", data: plans });
});

export const upload = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
  const file = (req as FileRequest).file;
  if (!file) return res.status(400).json({ status: "error", message: "An Excel file is required" });
  const plans = await service.preview(file.buffer);
  const saved = await service.replace(plans, userId(req));
  const fileUrl = await archiveUploadedFile(file, "export_plan_excel", userId(req));
  res.status(201).json({ status: "success", data: saved, file_url: fileUrl, message: "Export plan uploaded successfully" });
});
