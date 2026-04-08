import type { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

function authenticateToken(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (!token) return res.status(401).json({
    error: "Access denied. No token provided."
  });

  try {
    const verified = jwt.verify(token, process.env.JWT_SECRET as string);
    (req as any).user = verified;
    next();
  } catch (error) {
    res.status(401).json({
      error: "Invalid or expired token"
    })
  }
}

export { authenticateToken };
