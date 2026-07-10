import { Request, Response } from "express";
import * as eventService from "../services/event.service";

export const getAllEvents = async (req: Request, res: Response) => {
  try {
    const events = await eventService.getAllEvents();
    res.status(200).json({ status: "success", data: events });
  } catch (error: any) {
    res.status(500).json({ status: "error", message: error.message });
  }
};

export const getEventById = async (req: Request, res: Response) => {
  try {
    const id = parseInt(req.params.id as string, 10);
    const event = await eventService.getEventById(id);
    if (!event) {
      return res.status(404).json({ status: "error", message: "Event not found" });
    }
    res.status(200).json({ status: "success", data: event });
  } catch (error: any) {
    res.status(500).json({ status: "error", message: error.message });
  }
};

export const createEvent = async (req: Request, res: Response) => {
  try {
    const event = await eventService.createEvent(req.body);
    res.status(201).json({ status: "success", data: event });
  } catch (error: any) {
    res.status(500).json({ status: "error", message: error.message });
  }
};

export const updateEvent = async (req: Request, res: Response) => {
  try {
    const id = parseInt(req.params.id as string, 10);
    const event = await eventService.updateEvent(id, req.body);
    if (!event) {
      return res.status(404).json({ status: "error", message: "Event not found" });
    }
    res.status(200).json({ status: "success", data: event });
  } catch (error: any) {
    res.status(500).json({ status: "error", message: error.message });
  }
};

export const deleteEvent = async (req: Request, res: Response) => {
  try {
    const id = parseInt(req.params.id as string, 10);
    const success = await eventService.deleteEvent(id);
    if (!success) {
      return res.status(404).json({ status: "error", message: "Event not found" });
    }
    res.status(200).json({ status: "success", message: "Event deleted successfully" });
  } catch (error: any) {
    res.status(500).json({ status: "error", message: error.message });
  }
};
