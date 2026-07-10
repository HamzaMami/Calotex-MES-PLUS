import Joi from "joi";

export const createProductSchema = Joi.object({
  name: Joi.string().required(),
  lead_engineer_id: Joi.number().integer().positive().allow(null).optional(),
  technical_milestone: Joi.string().allow(null, "").optional(),
  validation_status: Joi.string().allow(null, "").optional(),
  final_approval: Joi.boolean().default(false),
});

export const updateProductSchema = Joi.object({
  name: Joi.string().optional(),
  lead_engineer_id: Joi.number().integer().positive().allow(null).optional(),
  technical_milestone: Joi.string().allow(null, "").optional(),
  validation_status: Joi.string().allow(null, "").optional(),
  final_approval: Joi.boolean().optional(),
}).min(1);
