import Joi from "joi";

export const createRoleSchemaJoi = Joi.object({
  name: Joi.string().lowercase().pattern(/^[a-z0-9_-]+$/).required().messages({
    "string.pattern.base":
      "name must be lowercase alphanumeric (e.g. 'quality_lead')",
  }),
  description: Joi.string().allow(null, "").optional(),
});

export const updateRoleSchemaJoi = Joi.object({
  name: Joi.string().lowercase().pattern(/^[a-z0-9_-]+$/).optional(),
  description: Joi.string().allow(null, "").optional(),
}).min(1);

export const setPermissionsSchemaJoi = Joi.object({
  permission_ids: Joi.array().items(Joi.number().integer().positive()).required(),
});
