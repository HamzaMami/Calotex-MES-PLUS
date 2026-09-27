import Joi from "joi";

export const createRoleSchemaJoi = Joi.object({
  name: Joi.string().trim().min(2).max(50).required().messages({
    "string.empty": "Role name is required",
    "string.min": "Role name must be at least 2 characters",
    "string.max": "Role name cannot exceed 50 characters",
  }),
  description: Joi.string().allow(null, "").optional(),
});

export const updateRoleSchemaJoi = Joi.object({
  name: Joi.string().trim().min(2).max(50).optional(),
  description: Joi.string().allow(null, "").optional(),
}).min(1);

export const setPermissionsSchemaJoi = Joi.object({
  permission_ids: Joi.array().items(Joi.number().integer().positive()).required(),
});
