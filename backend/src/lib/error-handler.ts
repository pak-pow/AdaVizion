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
    let state = "exists";

    switch(type) {
      case "STUDENT":
        resourceName = "Student number or email";
        break;
      case "LANDMARK":
        resourceName = "Landmark";
        state = "visited";
        break;
      case "QUIZ":
        resourceName = "Quiz";
        state = "answered";
        break;
      default:
        break;
    }

    return res.status(409).json({
      type: type,
      code: `DUPLICATE_${type}`,
      message: `${resourceName} already ${state}`
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
