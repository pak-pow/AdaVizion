import type { Response } from "express";
import { ERRORS } from "../constants/error-maps";
import type { ErrorType } from "../types/errors.types";

function handleControllerError(
  res: Response,
  error: any,
  type: ErrorType = "SERVER"
) {
  const errorDetails = ERRORS.find((err) => err.message === error.message);

  if (errorDetails) {
    const { status, ...details } = errorDetails;

    return res.status(status).json(details);
  }

  // Prisma uniquue cons
  if (error.code === "P2002") {
    let resourceName = "Resource";

    if (type === "STUDENT") resourceName = "Student number or email";
    if (type === "LANDMARK") resourceName = "Landmark visit";
    if (type === "QUIZ") resourceName = "Quiz submission";

    return res.status(409).json({
      type: type,
      code: "DUPLICATE",
      message: `${resourceName} already exists`
    });
  }

  console.error(error);
  return res.status(500).json({
    type: "SERVER",
    code: "INTERNAL_SERVER_ERROR",
    message: "Internal Server Error"
  });
}

export {
  handleControllerError
}
