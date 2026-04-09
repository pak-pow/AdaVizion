import type { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";
import { handleControllerError } from "../lib/error-handler";

function authenticateToken(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (!token) {
    return handleControllerError(
      res,
      new Error("Access denied due to missing token"),
      "AUTH"
    );
  }

  try {
    const verified = jwt.verify(token, process.env.JWT_SECRET as string);
    (req as any).user = verified;
    next();
  } catch (error) {
    return handleControllerError(
      res,
      new Error("Invalid or expired token"),
      "AUTH"
    );
  }
}

export { authenticateToken };
