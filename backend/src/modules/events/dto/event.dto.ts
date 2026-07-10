import Joi from "joi";

export const createEventSchema = Joi.object({
  title: Joi.string().required(),
  type: Joi.string().valid("technical", "quality", "export").required(),
  event_date: Joi.date().iso().required(),
});

export const updateEventSchema = Joi.object({
  title: Joi.string().optional(),
  type: Joi.string().valid("technical", "quality", "export").optional(),
  event_date: Joi.date().iso().optional(),
}).min(1);
