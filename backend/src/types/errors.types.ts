type ErrorType = "STUDENT" | "LANDMARK" | "QUIZ" | "SERVER";

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
