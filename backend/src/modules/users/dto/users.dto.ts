import Joi from "joi";

export const createUserSchemaJoi = Joi.object({
  name: Joi.string().min(1).required(),
  email: Joi.string().email().required(),
  role_id: Joi.number().integer().positive().required(),
});

export const updateUserSchemaJoi = Joi.object({
  name: Joi.string().min(1).optional(),
  role_id: Joi.number().integer().positive().allow(null).optional(),
  status: Joi.string().valid("active", "pending", "inactive").optional(),
}).min(1);

export const setStatusSchemaJoi = Joi.object({
  status: Joi.string().valid("active", "pending", "inactive").required(),
});
