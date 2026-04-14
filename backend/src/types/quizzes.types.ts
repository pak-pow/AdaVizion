import type { Quiz, Question } from "../../generated/prisma/client";

type SeedQuestion = Omit<Question, "question_id" | "quiz_id">

type ViewQuestion = Omit<Question, "correct_idx"> & {
  correct_idx?: number;
  your_answer?: number;
}

interface Answer {
  question_id: number;
  selected_idx: number;
}

interface QuestionResult {
  info: Question;
  performance: {
    your_answer: number;
    is_correct: boolean;
    points_earned: number;
  };
}

type SeedQuiz = Omit<Quiz, "quiz_id" | "max_score" | "passing_score" | "created_at"> & {
  questions: SeedQuestion[]
}

interface QuizSubmitBody {
  answers: Answer[];
}

interface QuizResult {
  totalScore: number;
  breakdown: QuestionResult[];
}

export type {
  SeedQuestion,
  ViewQuestion,
  Answer,
  QuestionResult,
  SeedQuiz,
  QuizSubmitBody,
  QuizResult
}
