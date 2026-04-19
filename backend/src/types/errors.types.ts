type ErrorType = "AUTH" | "STUDENT" | "LANDMARK" | "QUIZ" | "ACHIEVEMENT" | "SERVER";

interface ErrorDetails {
  type: ErrorType,
  code: string,
  status: number,
  message: string
}

export type {
  ErrorType,
  ErrorDetails
}
