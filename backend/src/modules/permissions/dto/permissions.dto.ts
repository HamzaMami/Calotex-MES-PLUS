import Joi from "joi";
import { z } from "zod";

export const createPermissionSchemaJoi = Joi.object({
  name: Joi.string()
    .pattern(/^[a-z0-9_-]+:[a-z0-9_-]+$/)
    .required()
    .messages({
      "string.pattern.base":
        "name must be in the form 'resource:action' (lowercase, e.g. users:create)",
    }),
  description: Joi.string().allow(null, "").optional(),
});

// Zod equivalent (single source of truth is Joi here; Zod kept for parity).
export const createPermissionSchemaZod = z.object({
  name: z.string().regex(/^[a-z0-9_-]+:[a-z0-9_-]+$/),
  description: z.string().nullable().optional(),
});
