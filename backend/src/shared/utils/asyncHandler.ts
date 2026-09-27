import { Request, Response, NextFunction, RequestHandler } from "express";

/**
 * Higher-order function that wraps async Express route handlers.
 * Any rejected promise or thrown error will automatically be passed to `next(err)`
 * so that Express's global error middleware handles it cleanly without try/catch boilerplate.
 */
export const asyncHandler = (fn: (req: Request, res: Response, next: NextFunction) => Promise<any>): RequestHandler => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};
