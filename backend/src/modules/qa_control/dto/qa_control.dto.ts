import Joi from "joi";

const code = Joi.string().pattern(/^\d{5}$/).required();
const optionalCode = Joi.string().pattern(/^\d{5}$/).allow("");
const serial = Joi.string().pattern(/^W\d{9}$/).required();
const optionalSerial = Joi.string().pattern(/^W\d{9}$/).allow("");

export const listQuerySchema = Joi.object({
  year: Joi.number().integer().min(2000).max(2100).required(),
  week: Joi.number().integer().min(1).max(53).required(),
}).required();

export const createSchema = Joi.object({
  product_code: Joi.string().trim().min(1).max(100).required(),
  year: Joi.number().integer().min(2000).max(2100).required(),
  calendar_week_kw: Joi.number().integer().min(1).max(53).required(),
  first_control_id: code,
  last_control_id: optionalCode,
  first_serial_number: serial,
  last_serial_number: optionalSerial,
}).required();
