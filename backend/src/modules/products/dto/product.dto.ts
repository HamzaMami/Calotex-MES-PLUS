import Joi from "joi";

export const createProductSchema = Joi.object({
  product_code: Joi.string().pattern(/^W\d{4}-\d{4}$/).required(),
  name: Joi.string().required(),
  assembly_pdf: Joi.string().allow(null, "").optional(),
  product_photo: Joi.string().allow(null, "").optional(),
  client_name: Joi.string().required(),
  category: Joi.string().required(),
  lead_engineer_id: Joi.number().integer().positive().allow(null).optional(),
  technical_milestone: Joi.string().allow(null, "").optional(),
  validation_status: Joi.string().allow(null, "").optional(),
  final_approval: Joi.boolean().default(false),
});

export const updateProductSchema = Joi.object({
  product_code: Joi.string().pattern(/^W\d{4}-\d{4}$/).optional(),
  name: Joi.string().optional(),
  assembly_pdf: Joi.string().allow(null, "").optional(),
  product_photo: Joi.string().allow(null, "").optional(),
  client_name: Joi.string().optional(),
  category: Joi.string().optional(),
  lead_engineer_id: Joi.number().integer().positive().allow(null).optional(),
  technical_milestone: Joi.string().allow(null, "").optional(),
  validation_status: Joi.string().allow(null, "").optional(),
  final_approval: Joi.boolean().optional(),
}).min(1);
