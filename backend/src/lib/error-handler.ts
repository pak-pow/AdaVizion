import type { Response } from "express";
import { LANDMARK_ERRORS, QUIZ_ERRORS, STUDENT_ERRORS } from "../constants/error-maps";

function handleControllerError(
  res: Response,
  error: any,
  errorMap: Record<string, number>
) {
  const errorMessage = error.message as string;
  const statusCode = errorMap[errorMessage];

  if (statusCode) {
    return res.status(statusCode).json({
      error: errorMessage
    });
  }

  if (error.code === "P2002") {
    let resourceName = "Resource";

    if (error === STUDENT_ERRORS) resourceName = "Student number or email";
    if (error === LANDMARK_ERRORS) resourceName = "Landmark visit";
    if (error === QUIZ_ERRORS) resourceName = "Quiz submission";

    return res.status(409).json({
      error: `${resourceName} already exists`
    });
  }

  console.error(error);
  return res.status(500).json({
    error: "Internal Server Error"
  });
}

export {
  handleControllerError
}
