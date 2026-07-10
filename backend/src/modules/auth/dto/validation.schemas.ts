import Joi from "joi";
import { z } from "zod";

export const loginSchemaJoi = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required(),
});

// Joi validation schemas
// Note: confirmPassword is validated client-side by Flutter before the request is made.
export const registerSchemaJoi = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(8).required(),
  name: Joi.string().min(1).required(),
  roleId: Joi.number().integer().positive().required(),
});

export const createUserByAdminSchemaJoi = Joi.object({
  email: Joi.string().email().required(),
  roleId: Joi.number().integer().positive().required(),
});

// Zod validation schemas
export const registerSchemaZod = z
  .object({
    email: z.string().email(),
    password: z.string().min(8),
    confirmPassword: z.string(),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Passwords must match",
    path: ["confirmPassword"],
  });

export const loginSchemaZod = z.object({
  email: z.string().email(),
  password: z.string(),
});

export const completeRegistrationSchemaZod = z
  .object({
    fullName: z.string().min(1),
    password: z.string().min(8),
    passwordConfirm: z.string(),
  })
  .refine((data) => data.password === data.passwordConfirm, {
    message: "Passwords must match",
    path: ["passwordConfirm"],
  });