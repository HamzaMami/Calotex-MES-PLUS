import Joi from "joi";

export const createManufacturingOrderSchema = Joi.object({
  product_id: Joi.number().integer().positive().required(),
  status: Joi.string().valid("in_production", "pending", "quality_control", "completed").required(),
  target_quantity: Joi.number().integer().min(1).required(),
  good_quantity: Joi.number().integer().min(0).default(0),
  reject_quantity: Joi.number().integer().min(0).default(0),
  qa_quantity: Joi.number().integer().min(0).default(0),
  start_date: Joi.date().allow(null).optional(),
  end_date: Joi.date().allow(null).optional(),
});

export const updateManufacturingOrderSchema = Joi.object({
  product_id: Joi.number().integer().positive().optional(),
  status: Joi.string().valid("in_production", "pending", "quality_control", "completed").optional(),
  target_quantity: Joi.number().integer().min(1).optional(),
  good_quantity: Joi.number().integer().min(0).optional(),
  reject_quantity: Joi.number().integer().min(0).optional(),
  qa_quantity: Joi.number().integer().min(0).optional(),
  start_date: Joi.date().allow(null).optional(),
  end_date: Joi.date().allow(null).optional(),
}).min(1);
