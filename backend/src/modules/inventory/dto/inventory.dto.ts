import Joi from "joi";

export const createInventorySchema = Joi.object({
  item_name: Joi.string().required(),
  sku: Joi.string().allow(null, "").optional(),
  quantity: Joi.number().integer().min(0).default(0),
  unit: Joi.string().default("pcs"),
  location: Joi.string().allow(null, "").optional(),
  last_restocked: Joi.date().allow(null).optional(),
});

export const updateInventorySchema = Joi.object({
  item_name: Joi.string().optional(),
  sku: Joi.string().allow(null, "").optional(),
  quantity: Joi.number().integer().min(0).optional(),
  unit: Joi.string().optional(),
  location: Joi.string().allow(null, "").optional(),
  last_restocked: Joi.date().allow(null).optional(),
}).min(1);
