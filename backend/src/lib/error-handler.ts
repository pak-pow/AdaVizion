import type { Response } from "express";
import { ERRORS } from "../constants/error-maps";
import type { ErrorDetails, ErrorType } from "../types/errors.types";
import { ZodError } from "zod";

function handleControllerError(
  res: Response,
  error: any,
  type: ErrorType = "SERVER"
) {
  // Zod validation errors
  if (error instanceof ZodError) {
    const errorMessage = error.issues[0]?.message || "Invalid request data";

    return res.status(400).json({
      type: type,
      code: "VALIDATION_ERROR",
      message: errorMessage
    });
  }

  const errorDetails = ERRORS.find((err) => err.message === error.message);

  // Client errors
  if (errorDetails) {
    const { status, ...details } = errorDetails;

    return res.status(status).json(details);
  }

  // Prisma unique constraint errors
  if (error.code === "P2002") {
    let resourceName = "Resource";

    if (type === "STUDENT") resourceName = "Student number or email";
    if (type === "LANDMARK") resourceName = "Landmark visit";
    if (type === "QUIZ") resourceName = "Quiz submission";

    return res.status(409).json({
      type: type,
      code: `DUPLICATE_${type}`,
      message: `${resourceName} already exists`
    });
  }

  console.error(error);

  // Server errors
  return res.status(500).json({
    type: "SERVER",
    code: "INTERNAL_SERVER_ERROR",
    message: "Internal Server Error"
  });
}

export {
  handleControllerError
}
