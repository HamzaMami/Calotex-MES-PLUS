import Joi from "joi";

const year = Joi.number().integer().min(2000).max(2100).required();
const calendarWeek = Joi.number().integer().min(1).max(53).required();

export const exportPlanSchema = Joi.object({
  calendar_week_kw: calendarWeek,
  year,
  order_number: Joi.string().trim().max(100).allow(null, ""),
  product_code: Joi.string().trim().min(1).max(100).required(),
  quantity: Joi.number().integer().min(0).max(2147483647).required(),
  destination: Joi.string().trim().min(1).max(255).required(),
  status: Joi.string().valid("pending", "in_production", "completed").optional(),
}).required();

export const updateExportPlanSchema = Joi.object({
  calendar_week_kw: Joi.number().integer().min(1).max(53),
  year: Joi.number().integer().min(2000).max(2100),
  order_number: Joi.string().trim().max(100).allow(null, ""),
  product_code: Joi.string().trim().min(1).max(100),
  quantity: Joi.number().integer().min(0).max(2147483647),
  destination: Joi.string().trim().min(1).max(255),
  status: Joi.string().valid("pending", "in_production", "completed"),
}).min(1).required();

export const exportPlanListQuerySchema = Joi.object({
  year: Joi.number().integer().min(2000).max(2100),
}).unknown(false);
