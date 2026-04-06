import type { Quiz, Question } from "../../generated/prisma/client";

type SeedQuestion = Omit<Question, "question_id" | "quiz_id">

type ViewQuestion = Omit<Question, "correct_idx"> & {
  your_answer?: number;
}

interface Answer {
  question_id: number;
  selected_idx: number;
}

type SeedQuiz = Omit<Quiz, "quiz_id" | "max_score" | "passing_score" | "created_at"> & {
  questions: SeedQuestion[]
}

interface QuizSubmitBody {
  answers: Answer[];
}

export type {
  SeedQuestion,
  ViewQuestion,
  Answer,
  SeedQuiz,
  QuizSubmitBody,
}
