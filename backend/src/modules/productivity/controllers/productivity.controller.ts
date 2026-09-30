import { Request, Response } from "express";
import { asyncHandler } from "../../../shared/utils/asyncHandler";
import { AuthenticatedRequest } from "../../auth/middleware/auth.midlleware";
import * as service from "../services/productivity.service";
import { archiveUploadedFile } from "../../../shared/services/supabase-storage.service";

type FileRequest = Request & { file?: Express.Multer.File };

const userId = (req: Request) => (req as AuthenticatedRequest).user?.id ?? null;

export const list = asyncHandler(async (_req: Request, res: Response) => {
  res.json({ status: "success", data: await service.list() });
});

export const upload = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
  const file = (req as FileRequest).file;
  if (!file) return res.status(400).json({ status: "error", message: "An Excel file is required" });
  const selectedYear = Number(req.body.year);
  const selectedMonth = Number(req.body.month);
  const percentage = Number(String(req.body.productivity_percentage ?? "").replace(",", "."));
  if (
    !Number.isInteger(selectedYear) || selectedYear < 2000 || selectedYear > 2100 ||
    !Number.isInteger(selectedMonth) || selectedMonth < 1 || selectedMonth > 12 ||
    !Number.isFinite(percentage) || percentage < 0 || percentage > 100
  ) {
    return res.status(400).json({
      status: "error",
      message: "Select a valid month and enter a productivity percentage from 0 to 100",
    });
  }
  const rows = [{
    calendar_week_kw: selectedMonth,
    year: selectedYear,
    productivity_percentage: percentage,
  }];
  res.status(201).json({
    status: "success",
    data: await service.replace(rows, userId(req)),
    file_url: await archiveUploadedFile(file, "productivity_excel", userId(req)),
    message: "Productivity data uploaded successfully",
  });
});

export const save = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
  const week = Number(req.body.calendar_week_kw);
  const year = Number(req.body.year);
  const percentage = Number(
    String(req.body.productivity_percentage ?? "")
      .replace("%", "")
      .replace(",", ".")
      .trim(),
  );
  if (
    !Number.isInteger(week) ||
    week < 1 ||
    week > 53 ||
    !Number.isInteger(year) ||
    year < 2000 ||
    year > 2100 ||
    !Number.isFinite(percentage) ||
    percentage < 0
  ) {
    return res.status(400).json({
      status: "error",
      message: "Enter a valid calendar week, year and productivity percentage",
    });
  }
  res.status(200).json({
    status: "success",
    data: await service.upsert(
      {
        calendar_week_kw: week,
        year,
        productivity_percentage: percentage,
      },
      userId(req),
    ),
    message: "Productivity saved successfully",
  });
});

export const remove = asyncHandler(async (req: Request, res: Response) => {
  const year = Number(req.params.year);
  const week = Number(req.params.week);
  if (
    !Number.isInteger(year) ||
    year < 2000 ||
    year > 2100 ||
    !Number.isInteger(week) ||
    week < 1 ||
    week > 53
  ) {
    return res.status(400).json({ status: "error", message: "Invalid year or calendar week" });
  }
  const removed = await service.remove(year, week);
  if (!removed) {
    return res.status(404).json({ status: "error", message: "Productivity record not found" });
  }
  res.json({ status: "success", message: "Productivity record deleted successfully" });
});
