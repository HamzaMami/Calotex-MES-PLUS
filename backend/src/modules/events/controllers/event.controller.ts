import { Request, Response } from "express";
import * as eventService from "../services/event.service";
import { asyncHandler } from "../../../shared/utils/asyncHandler";

export const getAllEvents = asyncHandler(async (req: Request, res: Response) => {
  const page = req.query.page ? parseInt(req.query.page as string, 10) : undefined;
  const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : undefined;

  const events = await eventService.getAllEvents(page, limit);
  res.status(200).json({ status: "success", data: events });
});

export const getEventById = asyncHandler(async (req: Request, res: Response) => {
  const id = parseInt(req.params.id as string, 10);
  const event = await eventService.getEventById(id);
  if (!event) {
    return res.status(404).json({ status: "error", message: "Event not found" });
  }
  res.status(200).json({ status: "success", data: event });
});

export const createEvent = asyncHandler(async (req: Request, res: Response) => {
  const event = await eventService.createEvent(req.body);
  res.status(201).json({ status: "success", data: event });
});

export const updateEvent = asyncHandler(async (req: Request, res: Response) => {
  const id = parseInt(req.params.id as string, 10);
  const event = await eventService.updateEvent(id, req.body);
  if (!event) {
    return res.status(404).json({ status: "error", message: "Event not found" });
  }
  res.status(200).json({ status: "success", data: event });
});

export const deleteEvent = asyncHandler(async (req: Request, res: Response) => {
  const id = parseInt(req.params.id as string, 10);
  const success = await eventService.deleteEvent(id);
  if (!success) {
    return res.status(404).json({ status: "error", message: "Event not found" });
  }
  res.status(200).json({ status: "success", message: "Event deleted successfully" });
});
