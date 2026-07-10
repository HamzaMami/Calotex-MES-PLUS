import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";
import Joi from "joi";
import { ZodSchema, ZodError, z } from "zod"; 
import { IJwtPayload } from "../interfaces/auth.interface";

// Custom interface to extend Express Request and avoid 'any'
export interface AuthenticatedRequest extends Request {
  user?: IJwtPayload;
}

export const authenticate = (
  req: AuthenticatedRequest, 
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        message: "Unauthorized",
      });
    }

    const token = authHeader.split(" ")[1];

    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as IJwtPayload;

    req.user = decoded;

    next();
  } catch (error) {
    return res.status(401).json({
      message: "Invalid token",
    });
  }
};

export const validateRequest = (schema: Joi.ObjectSchema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const { error } = schema.validate(req.body, { abortEarly: false });
    if (error) {
      return res.status(400).json({
        message: "Validation error",
        details: error.details.map((detail) => detail.message),
      });
    }
    next();
  };
};

export const validateWithZod = (schema: ZodSchema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      schema.parse(req.body);
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        return res.status(400).json({
          message: "Validation error",
          details: error.issues.map((issue: z.ZodIssue) => issue.message),
        });
      }
      return res.status(500).json({ message: "Internal server error" });
    }
  };
};