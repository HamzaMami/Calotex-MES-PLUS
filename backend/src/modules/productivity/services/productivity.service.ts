import ExcelJS from "exceljs";
import pool from "../../../config/db";

export interface ProductivityRow {
  calendar_week_kw: number;
  year: number;
  productivity_percentage: number;
}

const cellValue = (value: unknown): unknown => {
  if (value && typeof value === "object") {
    if ("result" in value) return (value as { result?: unknown }).result;
    if ("richText" in value) {
      return (value as { richText: Array<{ text?: string }> }).richText
        .map((part) => part.text ?? "")
        .join("");
    }
  }
  return value;
};

const text = (value: unknown) => String(cellValue(value) ?? "").trim();

const yearFromValue = (value: unknown): number | undefined => {
  if (value instanceof Date && !Number.isNaN(value.getTime())) {
    return value.getFullYear();
  }
  const match = text(value).match(/\b(20\d{2})\b/);
  return match ? Number(match[1]) : undefined;
};

const parseNumber = (value: unknown): number => {
  const match = text(value).replace(",", ".").match(/-?\d+(?:\.\d+)?/);
  return match ? Number(match[0]) : NaN;
};

const parsePercentage = (value: unknown): number => {
  const percentage = parseNumber(value);
  if (!Number.isFinite(percentage)) return NaN;
  return percentage >= 0 && percentage <= 1 ? percentage * 100 : percentage;
};

const parseHorizontalTemplate = (
  sheet: ExcelJS.Worksheet,
  selectedYear?: number,
  selectedMonth?: number,
): ProductivityRow[] => {
  const weekColumns = new Map<number, number>();
  let productivityRow = 0;
  let year: number | undefined;

  sheet.eachRow((row, rowNumber) => {
    row.eachCell((cell, columnNumber) => {
      const value = cell.value;
      year ??= yearFromValue(value);
      const valueText = text(value);
      const weekMatch = valueText.match(/^KW\s*[-_]?\s*(\d{1,2})$/i);
      if (weekMatch) weekColumns.set(columnNumber, Number(weekMatch[1]));
      if (/produktivit[aä]t|productivit[eé]|productivity/i.test(valueText)) {
        productivityRow = rowNumber;
      }
    });
  });

  if (!productivityRow) {
    sheet.eachRow((row, rowNumber) => {
      const hasProductivityLabel = Array.from(
        { length: sheet.columnCount },
        (_, index) => text(row.getCell(index + 1).value),
      ).some((value) => /produktivit[aä]t|productivit[eé]|productivity/i.test(value));
      if (hasProductivityLabel) productivityRow = rowNumber;
    });
  }
  if (!productivityRow) return [];
  const templateYear = selectedYear ?? year ?? new Date().getFullYear();

  const rowValues = Array.from(
    { length: sheet.columnCount },
    (_, index) => sheet.getRow(productivityRow).getCell(index + 1).value,
  );
  const productivityCells: Array<{
    value: unknown;
    format?: string;
    columnNumber: number;
  }> = [];
  sheet.getRow(productivityRow).eachCell((cell, columnNumber) => {
    productivityCells.push({
      value: cell.value,
      format: cell.numFmt,
      columnNumber,
    });
  });
  const labelCell = productivityCells.find(({ value }) =>
    /produktivit[aä]t|productivit[eé]|productivity/i.test(text(value)),
  );
  const percentageCells = productivityCells
    .filter(({ value, format, columnNumber }) =>
      (!labelCell || columnNumber > labelCell.columnNumber) &&
      (text(value).includes("%") || format?.includes("%")),
    )
    .map(({ value, columnNumber }) => ({
      columnNumber,
      percentage: parsePercentage(value),
    }))
    .filter(({ percentage }) =>
      Number.isFinite(percentage) && percentage >= 0 && percentage <= 100,
    )
    .sort((a, b) => b.percentage - a.percentage);
  const totalPercentage = percentageCells[0]?.percentage;
  const monthKey = selectedMonth && selectedMonth >= 1 && selectedMonth <= 12
    ? selectedMonth
    : weekColumns.size > 0
    ? Math.max(...Array.from(weekColumns.values()))
    : 1;
  if (totalPercentage === undefined || !Number.isFinite(totalPercentage)) {
    let workbookPercentage: number | undefined;
    sheet.eachRow((row) => {
      row.eachCell((cell) => {
        const value = parsePercentage(cell.value);
        if (
          workbookPercentage === undefined &&
          Number.isFinite(value) &&
          value >= 1 &&
          value <= 100 &&
          text(cell.value).includes("%")
        ) {
          workbookPercentage = value;
        }
      });
    });
    if (workbookPercentage === undefined) return [];
    return [{
      calendar_week_kw: monthKey,
      year: templateYear,
      productivity_percentage: workbookPercentage,
    }];
  }
  return [{
    calendar_week_kw: monthKey,
    year: templateYear,
    productivity_percentage: totalPercentage,
  }];
};

export const parseExcel = async (
  buffer: Buffer,
  selectedYear?: number,
  selectedMonth?: number,
): Promise<ProductivityRow[]> => {
  const workbook = new ExcelJS.Workbook();
  await workbook.xlsx.load(buffer as any);
  const sheet = workbook.worksheets[0];
  if (!sheet) throw new Error("The workbook does not contain a worksheet");

  const horizontalRows = parseHorizontalTemplate(sheet, selectedYear, selectedMonth);
  if (horizontalRows.length > 0) return horizontalRows;

  const rows: ProductivityRow[] = [];
  sheet.eachRow((row, rowNumber) => {
    if (rowNumber === 1) return;
    const values = Array.from({ length: sheet.columnCount }, (_, index) =>
      text(row.getCell(index + 1).value),
    );
    const weekMatch = values.find((value) => /^KW\s*\d{1,2}$/i.test(value));
    const week = weekMatch
      ? Number(weekMatch.match(/\d+/)?.[0])
      : parseNumber(values[0]);
    const year = values.find((value) => /^20\d{2}$/.test(value));
    const percentageValue = values
      .map((value) => ({ value, number: parseNumber(value) }))
      .find(({ value, number }) => value.includes("%") && Number.isFinite(number));
    const percentage = percentageValue?.number ?? parseNumber(values[values.length - 1]);

    if (
      Number.isInteger(week) &&
      week >= 1 &&
      week <= 53 &&
      year &&
      Number.isInteger(Number(year)) &&
      Number.isFinite(percentage) &&
      percentage >= 0
    ) {
      rows.push({
        calendar_week_kw: week,
        year: Number(year),
        productivity_percentage: percentage,
      });
    }
  });

  if (rows.length === 0) {
    throw new Error("Excel file must contain calendar week, year and productivity percentage");
  }
  return rows;
};

export const list = async (): Promise<ProductivityRow[]> => {
  const result = await pool.query(
    `SELECT calendar_week_kw, year, productivity_percentage
       FROM productivity_records
      ORDER BY year, calendar_week_kw`,
  );
  return result.rows;
};

export const replace = async (rows: ProductivityRow[], userId: number | null) => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    await client.query("DELETE FROM productivity_records WHERE calendar_week_kw > 12");
    for (const row of rows) {
      await client.query(
        `DELETE FROM productivity_records
          WHERE year = $1 AND calendar_week_kw = $2`,
        [row.year, row.calendar_week_kw],
      );
      await client.query(
        `INSERT INTO productivity_records
          (calendar_week_kw, year, productivity_percentage, created_by)
         VALUES ($1, $2, $3, $4)
         ON CONFLICT (year, calendar_week_kw)
         DO UPDATE SET productivity_percentage = EXCLUDED.productivity_percentage,
                       created_by = EXCLUDED.created_by,
                       updated_at = NOW()`,
        [row.calendar_week_kw, row.year, row.productivity_percentage, userId],
      );
    }
    await client.query("COMMIT");
    return list();
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
};

export const upsert = async (
  row: ProductivityRow,
  userId: number | null,
): Promise<ProductivityRow[]> => {
  await pool.query(
    `INSERT INTO productivity_records
      (calendar_week_kw, year, productivity_percentage, created_by)
     VALUES ($1, $2, $3, $4)
     ON CONFLICT (year, calendar_week_kw)
     DO UPDATE SET productivity_percentage = EXCLUDED.productivity_percentage,
                   created_by = EXCLUDED.created_by,
                   updated_at = NOW()`,
    [row.calendar_week_kw, row.year, row.productivity_percentage, userId],
  );
  return list();
};

export const remove = async (year: number, week: number): Promise<boolean> => {
  const result = await pool.query(
    `DELETE FROM productivity_records
      WHERE year = $1 AND calendar_week_kw = $2`,
    [year, week],
  );
  return (result.rowCount ?? 0) > 0;
};
