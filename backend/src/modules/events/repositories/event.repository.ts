import pool from "../../../config/db";
import { Event } from "../interfaces/event.interface";

const ALLOWED_EVENT_COLUMNS = new Set(["title", "type", "event_date"]);

export interface PaginatedResult<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
}

export const findAll = async (
  page?: number,
  limit?: number
): Promise<Event[] | PaginatedResult<Event>> => {
  if (page && limit) {
    const offset = (page - 1) * limit;
    const countResult = await pool.query("SELECT COUNT(*) FROM events");
    const total = parseInt(countResult.rows[0].count, 10);

    const dataResult = await pool.query(
      "SELECT * FROM events ORDER BY event_date ASC LIMIT $1 OFFSET $2",
      [limit, offset]
    );

    return {
      items: dataResult.rows,
      total,
      page,
      limit,
    };
  }

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
  const entries = Object.entries(eventData).filter(([key]) =>
    ALLOWED_EVENT_COLUMNS.has(key)
  );
  if (entries.length === 0) return null;

  const setClause = entries
    .map(([key], index) => `"${key}" = $${index + 2}`)
    .join(", ");
  const values = entries.map(([, value]) => value);

  const query = `UPDATE events SET ${setClause}, updated_at = NOW() WHERE id = $1 RETURNING *`;
  const result = await pool.query(query, [id, ...values]);

  return result.rows[0] || null;
};

export const deleteEvent = async (id: number): Promise<boolean> => {
  const result = await pool.query("DELETE FROM events WHERE id = $1", [id]);
  return (result.rowCount ?? 0) > 0;
};
