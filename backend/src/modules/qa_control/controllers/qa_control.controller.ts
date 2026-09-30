import { Response } from "express";
import { asyncHandler } from "../../../shared/utils/asyncHandler";
import { AuthenticatedRequest } from "../../auth/middleware/auth.midlleware";
import * as repository from "../repositories/qa_control.repository";

export const list = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
  const year = Number(req.query.year);
  const week = Number(req.query.week);
  res.status(200).json({ status: "success", data: await repository.findWeeklyProducts(year, week) });
});

export const create = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
  const createdBy = Number.isInteger(req.user?.id) ? req.user!.id : null;
  const data = {
    ...req.body,
    last_control_id: req.body.last_control_id || req.body.first_control_id,
    last_serial_number: req.body.last_serial_number || req.body.first_serial_number,
  };
  res.status(201).json({ status: "success", data: await repository.create(data, createdBy) });
});
