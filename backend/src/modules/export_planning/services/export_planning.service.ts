import ExcelJS from "exceljs";
import * as repository from "../repositories/export_planning.repository";
import {
  ExportPlan,
  ExportPlanInput,
} from "../interfaces/export_planning.interface";

const normalizeHeader = (value: unknown): string => {
  if (value && typeof value === "object" && "richText" in value) {
    value = (value as { richText: Array<{ text?: string }> }).richText
      .map((part) => part.text ?? "")
      .join("");
  }
  return String(value ?? "")
    .trim()
    .toLowerCase()
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_|_$/g, "");
};

const headerAliases: Record<string, string[]> = {
  kw: ["kw", "calendar_week", "calendar_week_kw", "calendarweek", "week", "kalenderwoche"],
  year: ["year", "jahr"],
  product_code: ["product_code", "productcode", "product", "product_number", "artikelnummer", "produktcode", "artikel"],
  order_number: ["order_number", "order_no", "order", "n_de_commande", "numero_de_commande"],
  quantity: ["quantity", "qty", "amount", "menge"],
  destination: ["destination", "dest", "customer", "ziel", "lieferort"],
};

const cellText = (value: unknown): string => {
  if (value && typeof value === "object" && "richText" in value) {
    return (value as { richText: Array<{ text?: string }> }).richText
      .map((part) => part.text ?? "")
      .join("")
      .trim();
  }
  return String(value ?? "").trim();
};

const excelDateYear = (value: unknown): number | undefined => {
  if (value instanceof Date && !Number.isNaN(value.getTime())) return value.getFullYear();
  const text = cellText(value);
  const match = text.match(/\b(20\d{2})\b/);
  return match ? Number(match[1]) : undefined;
};

const extractOrderNumber = (value: unknown): string => {
  const text = cellText(value);
  const backerOrder = text.match(/^B-\d+$/i);
  if (backerOrder) return backerOrder[0];
  const numeric = text.match(/^\d{4,12}/);
  if (numeric) return numeric[0];
  const named = text.match(/^[A-Z][A-Z0-9]*(?:\s+[A-Z]+)*\s+\d{3,}/i);
  return named ? named[0].trim() : "";
};

const findOrderNumber = (values: string[], productNameColumn: number): string => {
  const candidates = values.slice(0, productNameColumn - 1);
  const namedStockOrder = candidates.find((value) => /^lager$/i.test(value));
  if (namedStockOrder) return namedStockOrder;
  const backerOrder = candidates.find((value) => /^B-\d+$/i.test(value));
  if (backerOrder) return extractOrderNumber(backerOrder);
  const named = candidates.find((value) =>
    /^[A-Z][A-Z0-9]*(?:\s+[A-Z]+)*\s+\d{3,}/i.test(value),
  );
  if (named) return extractOrderNumber(named);
  const longNumeric = candidates.find((value) => /^\d{6,12}/.test(value));
  if (longNumeric) return extractOrderNumber(longNumeric);
  const numeric = candidates.find((value) => /^\d{4,5}/.test(value));
  return numeric ? extractOrderNumber(numeric) : "";
};

const parseCalotexTemplate = (worksheet: ExcelJS.Worksheet): ExportPlanInput[] | null => {
  let week: number | undefined;
  let year: number | undefined;
  let headerRow = 0;
  let quantityColumn = 0;
  let articleColumn = 0;
  let productNameColumn = 0;
  let orderNumberColumn = 0;

  worksheet.eachRow((row, rowNumber) => {
    row.eachCell((cell) => {
      const text = cellText(cell.value);
      const weekMatch = text.match(/^KW\s*[-_]?(\d{1,2})$/i);
      if (weekMatch) week = Number(weekMatch[1]);
      year ??= excelDateYear(cell.value);
    });
    if (!headerRow) {
      row.eachCell((cell, columnNumber) => {
        const normalized = normalizeHeader(cell.value);
        if (/^(qte|qte_|quantite|quantity)$/.test(normalized)) quantityColumn = columnNumber;
        if (normalized === "product_name") productNameColumn = columnNumber;
        if (normalized === "article") articleColumn = columnNumber;
        if (headerAliases.order_number.includes(normalized)) orderNumberColumn = columnNumber;
      });
      if (articleColumn && !productNameColumn) productNameColumn = articleColumn + 1;
      if (quantityColumn && productNameColumn) headerRow = rowNumber;
    }
  });

  if (!headerRow || !week || !year || !quantityColumn || !productNameColumn) return null;
  const templateWeek = week;
  const templateYear = year;

  const plans: ExportPlanInput[] = [];
  let destination = "";
  worksheet.eachRow((row, rowNumber) => {
    if (rowNumber <= headerRow) return;
    const values = Array.from({ length: worksheet.columnCount }, (_, index) =>
      cellText(row.getCell(index + 1).value),
    );
    const quantity = numberValue(row.getCell(quantityColumn).value);
    const orderNumber = findOrderNumber(values, values.length + 1);
    const productName = cellText(row.getCell(productNameColumn).value);
    const code = values.find(
      (value) => /^W\d{4}-\d{4}$/i.test(value) || /^[A-Z]?\d{3}-\d{3}$/i.test(value),
    );
    const rowDestination = values
      .slice(quantityColumn)
      .reverse()
      .find(
        (value) =>
          value &&
          !/^KW\s*\d+$/i.test(value) &&
          !/^\d+(?:[.,]\d+)?$/.test(value) &&
          !/^\d{1,2}[./-]\d{1,2}[./-]\d{2,4}$/.test(value),
      );
    if (rowDestination) destination = rowDestination;

    if (Number.isInteger(quantity) && quantity >= 0 && code && destination) {
      plans.push({
        calendar_week_kw: templateWeek,
        year: templateYear,
        order_number: orderNumber || null,
        product_code: code,
        quantity,
        destination,
      });
    }
  });
  return plans;
};

const numberValue = (value: unknown): number => {
  if (typeof value === "number") return value;
  if (value instanceof Date) return NaN;
  return Number(String(value ?? "").trim());
};

const weekValue = (value: unknown): number => {
  if (typeof value === "number") return value;
  const text = String(value ?? "").trim();
  const match = text.match(/^(?:kw[\s_-]*)?(\d{1,2})$/i);
  return match ? Number(match[1]) : NaN;
};

/** Parse the first worksheet. Headers are KW/year/product_code/quantity/destination. */
export const parseExcel = async (buffer: Buffer): Promise<ExportPlanInput[]> => {
  const workbook = new ExcelJS.Workbook();
  await workbook.xlsx.load(buffer as any);
  const worksheet = workbook.worksheets[0];
  if (!worksheet) throw new Error("The workbook does not contain a worksheet");

  const calotexPlans = parseCalotexTemplate(worksheet);
  if (calotexPlans) return calotexPlans;

  let headerRowNumber = 0;
  let headers: Record<string, number> = {};
  for (let rowNumber = 1; rowNumber <= Math.min(10, worksheet.rowCount); rowNumber += 1) {
    const candidate: Record<string, number> = {};
    worksheet.getRow(rowNumber).eachCell((cell, columnNumber) => {
      const header = normalizeHeader(cell.value);
      if (header) candidate[header] = columnNumber;
    });
    const matched = Object.values(headerAliases).filter((aliases) =>
      aliases.some((alias) => candidate[alias]),
    ).length;
    if (matched === Object.keys(headerAliases).length) {
      headerRowNumber = rowNumber;
      headers = candidate;
      break;
    }
  }
  const columnFor = (key: string): number | undefined =>
    headerAliases[key].map((alias) => headers[alias]).find((column) => column !== undefined);
  const kwColumn = columnFor("kw");
  const yearColumn = columnFor("year");
  const productCodeColumn = columnFor("product_code");
  const quantityColumn = columnFor("quantity");
  const destinationColumn = columnFor("destination");
  const orderNumberColumn = columnFor("order_number");
  if (!headerRowNumber || !kwColumn || !yearColumn || !productCodeColumn || !quantityColumn || !destinationColumn) {
    throw new Error("Excel file must contain KW, year, product_code, quantity and destination columns");
  }

  const plans: ExportPlanInput[] = [];
  worksheet.eachRow((row, rowNumber) => {
    if (rowNumber <= headerRowNumber) return;
    const productCode = String(row.getCell(productCodeColumn).value ?? "").trim();
    const destination = String(row.getCell(destinationColumn).value ?? "").trim();
    const plan = {
      calendar_week_kw: weekValue(row.getCell(kwColumn).value),
      year: numberValue(row.getCell(yearColumn).value),
      order_number: orderNumberColumn ? cellText(row.getCell(orderNumberColumn).value) || null : null,
      product_code: productCode,
      quantity: numberValue(row.getCell(quantityColumn).value),
      destination,
    };
    if (
      productCode ||
      destination ||
      String(row.getCell(kwColumn).value ?? "").trim() ||
      String(row.getCell(yearColumn).value ?? "").trim()
    ) {
      plans.push(plan);
    }
  });
  return plans;
};

export const validatePlans = (plans: ExportPlanInput[]): string[] => {
  const errors: string[] = [];
  plans.forEach((plan, index) => {
    if (!Number.isInteger(plan.calendar_week_kw) || plan.calendar_week_kw < 1 || plan.calendar_week_kw > 53) {
      errors.push(`Row ${index + 2}: KW must be an integer between 1 and 53`);
    }
    if (!Number.isInteger(plan.year) || plan.year < 2000 || plan.year > 2100) {
      errors.push(`Row ${index + 2}: year must be between 2000 and 2100`);
    }
    if (!plan.product_code || plan.product_code.length > 100) {
      errors.push(`Row ${index + 2}: product_code is required and must be at most 100 characters`);
    }
    if (!Number.isInteger(plan.quantity) || plan.quantity < 0) {
      errors.push(`Row ${index + 2}: quantity must be a non-negative integer`);
    }
    if (!plan.destination || plan.destination.length > 255) {
      errors.push(`Row ${index + 2}: destination is required and must be at most 255 characters`);
    }
  });
  return errors;
};

export const list = (year?: number) => repository.findAll(year);
export const get = (id: number) => repository.findById(id);
export const create = (input: ExportPlanInput, userId: number | null) => repository.create(input, userId);
export const update = (id: number, input: Partial<ExportPlanInput>, userId: number | null) =>
  repository.update(id, input, userId);
export const remove = (id: number, userId: number | null) => repository.remove(id, userId);
export const clearAll = (userId: number | null) => repository.clearAll(userId);
export const clearWeek = (year: number, week: number, userId: number | null) =>
  repository.clearWeek(year, week, userId);
export const replace = (plans: ExportPlanInput[], userId: number | null) =>
  repository.replaceExportPlans(plans, userId);

export const preview = async (buffer: Buffer): Promise<ExportPlanInput[]> => {
  const plans = await parseExcel(buffer);
  const errors = validatePlans(plans);
  if (errors.length > 0) {
    const error = new Error(errors.join("; "));
    (error as Error & { statusCode?: number }).statusCode = 400;
    throw error;
  }
  return plans;
};
