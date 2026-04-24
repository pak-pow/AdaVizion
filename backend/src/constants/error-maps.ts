import type { ErrorDetails } from "../types/errors.types";

const ERRORS: ErrorDetails[] = [
  // Authorization Errors
  {
    type: "AUTH",
    code: "MISSING_TOKEN",
    status: 401,
    message: "Access denied due to missing token"
  },
  {
    type: "AUTH",
    code: "INVALID_TOKEN",
    status: 401,
    message: "Invalid or expired token"
  },

  // Student Errors
  {
    type: "STUDENT",
    code: "STUDENT_NOT_FOUND",
    status: 404,
    message: "Student not found" 
  },
  {
    type: "STUDENT",
    code: "INCORRECT_CREDENTIALS",
    status: 401,
    message: "Incorrect student number or password" 
  },

  // Student Profile Picture Errors
  {
    type: "STUDENT",
    code: "ONLY_IMAGES_ALLOWED",
    status: 415,
    message: "Only image files are allowed" 
  },
  {
    type: "STUDENT",
    code: "IMAGE_MISSING",
    status: 400,
    message: "No file uploaded" 
  },
  {
    type: "STUDENT",
    code: "PROFILE_PIC_NOT_FOUND",
    status: 404,
    message: "Profile picture not found" 
  },
  {
    type: "STUDENT",
    code: "IMAGE_URL_UPLOAD_FAILED",
    status: 400,
    message: "Failed to link uploaded image to student profile" 
  },
  {
    type: "STUDENT",
    code: "IMAGE_FILE_UPLOAD_FAILED",
    status: 400,
    message: "Failed to upload profile picture" 
  },
  {
    type: "STUDENT",
    code: "EDIT_PROFILE_FAILED",
    status: 400,
    message: "Failed to edit student profile" 
  },
  {
    type: "STUDENT",
    code: "INCORRECT_PASSWORD",
    status: 403,
    message: "Incorrect password" 
  },
  {
    type: "STUDENT",
    code: "CHANGE_PASSWORD_FAILED",
    status: 400,
    message: "Failed to change password" 
  },

  // Landmark Errors
  {
    type: "LANDMARK",
    code: "LANDMARK_NOT_FOUND",
    status: 404,
    message: "Landmark not found" 
  },
  {
    type: "LANDMARK",
    code: "INVALID_QR",
    status: 403,
    message: "Invalid landmark QR code" 
  },
  {
    type: "LANDMARK",
    code: "QR_FAILED",
    status: 500,
    message: "Failed to process scan" 
  },

  // Quiz Errors
  {
    type: "QUIZ",
    code: "QUIZ_NOT_FOUND",
    status: 404,
    message: "Quiz not found" 
  },
  {
    type: "QUIZ",
    code: "QUIZ_LOCKED",
    status: 403,
    message: "Quiz requires more landmark visits to unlock" 
  },
  {
    type: "QUIZ",
    code: "INVALID_RESPONSE_FORMAT",
    status: 400,
    message: "Invalid question response data format" 
  },
  {
    type: "QUIZ",
    code: "ANSWER_COUNT_MISMATCH",
    status: 400,
    message: "Answer count does not match question count" 
  },
  {
    type: "QUIZ",
    code: "INVALID_QUESTION_ID",
    status: 400,
    message: "Invalid question ID" 
  },
  {
    type: "QUIZ",
    code: "QUIZ_EVALUATION_ERROR",
    status: 500,
    message: "Error evaluating quiz answers" 
  },
  {
    type: "QUIZ",
    code: "DB_TRANSAC_FAILED",
    status: 500,
    message: "Database transaction failed to return new quiz submission and updated progress" 
  }
];

export {
  ERRORS
}
