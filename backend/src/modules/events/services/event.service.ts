import * as eventRepository from "../repositories/event.repository";
import { Event } from "../interfaces/event.interface";

export const getAllEvents = async (): Promise<Event[]> => {
  return await eventRepository.findAll();
};

export const getEventById = async (id: number): Promise<Event | null> => {
  return await eventRepository.findById(id);
};

export const createEvent = async (
  eventData: Omit<Event, "id" | "created_at" | "updated_at">
): Promise<Event> => {
  return await eventRepository.create(eventData);
};

export const updateEvent = async (
  id: number,
  eventData: Partial<Event>
): Promise<Event | null> => {
  return await eventRepository.update(id, eventData);
};

export const deleteEvent = async (id: number): Promise<boolean> => {
  return await eventRepository.deleteEvent(id);
};
