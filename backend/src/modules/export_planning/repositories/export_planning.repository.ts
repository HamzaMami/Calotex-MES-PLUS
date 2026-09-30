import pool from "../../../config/db";
import {
  ExportPlan,
  ExportPlanAudit,
  ExportPlanInput,
} from "../interfaces/export_planning.interface";

const editableColumns = new Set([
  "calendar_week_kw",
  "year",
  "order_number",
  "product_code",
  "quantity",
  "destination",
  "status",
]);

const audit = async (
  client: any,
  exportPlanId: number | null,
  action: string,
  changedBy: number | null,
  oldValues: unknown,
  newValues: unknown,
) => {
  await client.query(
    `INSERT INTO export_plan_audit
       (export_plan_id, action, changed_by, old_values, new_values)
     VALUES ($1, $2, $3, $4::jsonb, $5::jsonb)`,
    [
      exportPlanId,
      action,
      changedBy,
      oldValues == null ? null : JSON.stringify(oldValues),
      newValues == null ? null : JSON.stringify(newValues),
    ],
  );
};

export const findAll = async (year?: number): Promise<ExportPlan[]> => {
  const result = year
    ? await pool.query(
        `SELECT * FROM export_plans
         WHERE year = $1
         ORDER BY order_number NULLS LAST, year, calendar_week_kw, product_code, id`,
        [year],
      )
    : await pool.query(
        "SELECT * FROM export_plans ORDER BY order_number NULLS LAST, year, calendar_week_kw, product_code, id",
      );
  return result.rows;
};

export const findById = async (id: number): Promise<ExportPlan | null> => {
  const result = await pool.query("SELECT * FROM export_plans WHERE id = $1", [id]);
  return result.rows[0] || null;
};

export const create = async (
  input: ExportPlanInput,
  createdBy: number | null,
): Promise<ExportPlan> => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const result = await client.query(
      `INSERT INTO export_plans
         (calendar_week_kw, year, order_number, product_code, quantity, destination, created_by)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [
        input.calendar_week_kw,
        input.year,
        input.order_number ?? null,
        input.product_code,
        input.quantity,
        input.destination,
        createdBy,
      ],
    );
    await audit(client, result.rows[0].id, "create", createdBy, null, result.rows[0]);
    await client.query("COMMIT");
    return result.rows[0];
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
};

export const update = async (
  id: number,
  input: Partial<ExportPlanInput>,
  changedBy: number | null,
): Promise<ExportPlan | null> => {
  const entries = Object.entries(input).filter(([key]) => editableColumns.has(key));
  if (entries.length === 0) return null;

  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const oldResult = await client.query("SELECT * FROM export_plans WHERE id = $1 FOR UPDATE", [id]);
    if (oldResult.rowCount === 0) {
      await client.query("ROLLBACK");
      return null;
    }
    const setClause = entries.map(([key], index) => `"${key}" = $${index + 2}`).join(", ");
    const result = await client.query(
      `UPDATE export_plans SET ${setClause}, updated_at = NOW()
       WHERE id = $1 RETURNING *`,
      [id, ...entries.map(([, value]) => value)],
    );
    await audit(client, id, "update", changedBy, oldResult.rows[0], result.rows[0]);
    await client.query("COMMIT");
    return result.rows[0];
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
};

export const remove = async (id: number, changedBy: number | null): Promise<boolean> => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const oldResult = await client.query("SELECT * FROM export_plans WHERE id = $1 FOR UPDATE", [id]);
    if (oldResult.rowCount === 0) {
      await client.query("ROLLBACK");
      return false;
    }
    await client.query("DELETE FROM export_plans WHERE id = $1", [id]);
    await audit(client, id, "delete", changedBy, oldResult.rows[0], null);
    await client.query("COMMIT");
    return true;
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
};

/** Replace the complete plan atomically and retain before/after audit data. */
export const replaceExportPlans = async (
  plans: ExportPlanInput[],
  changedBy: number | null,
): Promise<ExportPlan[]> => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const weeks = [...new Set(plans.map((plan) => `${plan.year}:${plan.calendar_week_kw}`))];
    const oldResult = await client.query(
      `SELECT * FROM export_plans
       WHERE (year, calendar_week_kw) IN (
         SELECT split_part(value, ':', 1)::int, split_part(value, ':', 2)::int
         FROM unnest($1::text[]) AS value
       )
       ORDER BY id`,
      [weeks],
    );
    await client.query(
      `DELETE FROM export_plans
       WHERE (year, calendar_week_kw) IN (
         SELECT split_part(value, ':', 1)::int, split_part(value, ':', 2)::int
         FROM unnest($1::text[]) AS value
       )`,
      [weeks],
    );
    for (const plan of plans) {
      await client.query(
        `INSERT INTO export_plans
           (calendar_week_kw, year, order_number, product_code, quantity, destination, created_by)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [
          plan.calendar_week_kw,
          plan.year,
          plan.order_number ?? null,
          plan.product_code,
          plan.quantity,
          plan.destination,
          changedBy,
        ],
      );
    }
    const newResult = await client.query(
      "SELECT * FROM export_plans ORDER BY order_number NULLS LAST, year, calendar_week_kw, product_code, id",
    );
    await audit(client, null, "replace", changedBy, oldResult.rows, newResult.rows);
    await client.query("COMMIT");
    return newResult.rows;
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
};

export const findAudit = async (exportPlanId?: number): Promise<ExportPlanAudit[]> => {
  const result = exportPlanId
    ? await pool.query(
        "SELECT * FROM export_plan_audit WHERE export_plan_id = $1 ORDER BY created_at DESC",
        [exportPlanId],
      )
    : await pool.query("SELECT * FROM export_plan_audit ORDER BY created_at DESC");
  return result.rows;
};

export const clearAll = async (changedBy: number | null): Promise<void> => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const oldResult = await client.query("SELECT * FROM export_plans ORDER BY id");
    await client.query("DELETE FROM export_plans");
    await audit(client, null, "clear", changedBy, oldResult.rows, null);
    await client.query("COMMIT");
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
};

export const clearWeek = async (
  year: number,
  week: number,
  changedBy: number | null,
): Promise<void> => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const oldResult = await client.query(
      "SELECT * FROM export_plans WHERE year = $1 AND calendar_week_kw = $2",
      [year, week],
    );
    await client.query(
      "DELETE FROM export_plans WHERE year = $1 AND calendar_week_kw = $2",
      [year, week],
    );
    await audit(client, null, "clear", changedBy, oldResult.rows, null);
    await client.query("COMMIT");
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
};
