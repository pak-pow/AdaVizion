const STUDENT_ERRORS: Record<string, number> = {
  "Student does not exist": 404,
  "Invalid student number or password": 401,
}

const LANDMARK_ERRORS: Record<string, number> = {
  "Landmark not found": 404,
  "Landmark already visited": 400,
  "Invalid landmark QR code": 403,
  "Failed to process scan": 500,
}

const QUIZ_ERRORS: Record<string, number> = {
  "Quiz not found": 404,
  "Quiz is locked. You need more XP to unlock it.": 403,
  "Invalid question response data format": 400,
  "Quiz already answered": 409,
  "Answer count does not match question count": 400,
  "Invalid question ID provided": 400,
  "Error evaluating quiz answers": 500,
  "Database transaction failed to return new quiz submission and updated progress": 500
}

export {
  STUDENT_ERRORS,
  LANDMARK_ERRORS,
  QUIZ_ERRORS
}
