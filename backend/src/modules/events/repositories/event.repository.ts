import pool from "../../../config/db";
import { Event } from "../interfaces/event.interface";

export const findAll = async (): Promise<Event[]> => {
  const result = await pool.query(
    "SELECT * FROM events ORDER BY event_date ASC"
  );
  return result.rows;
};

export const findById = async (id: number): Promise<Event | null> => {
  const result = await pool.query("SELECT * FROM events WHERE id = $1", [id]);
  return result.rows[0] || null;
};

export const create = async (
  eventData: Omit<Event, "id" | "created_at" | "updated_at">
): Promise<Event> => {
  const { title, type, event_date } = eventData;
  const result = await pool.query(
    `INSERT INTO events (title, type, event_date)
     VALUES ($1, $2, $3) RETURNING *`,
    [title, type, event_date]
  );
  return result.rows[0];
};

export const update = async (
  id: number,
  eventData: Partial<Event>
): Promise<Event | null> => {
  const keys = Object.keys(eventData);
  if (keys.length === 0) return null;

  const setClause = keys
    .map((key, index) => `"${key}" = $${index + 2}`)
    .join(", ");
  const values = keys.map((key) => (eventData as any)[key]);

  const query = `UPDATE events SET ${setClause} WHERE id = $1 RETURNING *`;
  const result = await pool.query(query, [id, ...values]);

  return result.rows[0] || null;
};

export const deleteEvent = async (id: number): Promise<boolean> => {
  const result = await pool.query("DELETE FROM events WHERE id = $1", [id]);
  return (result.rowCount ?? 0) > 0;
};
