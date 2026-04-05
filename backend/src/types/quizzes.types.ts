import { Prisma } from "../../generated/prisma/client";

interface BaseQuestion {
  question_text: string;
  choices: string[] | Prisma.JsonValue;
  item_points: number;
}

interface SeedQuestion extends BaseQuestion {
  correct_idx: number;
}

interface ViewQuestion extends BaseQuestion {
  question_id: number;
  your_answer?: number;
}

interface QuestionResult extends ViewQuestion {
  your_answer: number;
  correct_answer: number;
  is_correct: boolean;
  points_earned: number;
}

interface Answer {
  question_id: number;
  selected_idx: number;
}

interface BaseQuiz {
  name: string;
  required_xp: number;
}

interface SeedQuiz extends BaseQuiz {
  questions: SeedQuestion[]
}

interface ViewQuiz extends BaseQuiz {
  quiz_id: number;
}

interface QuizSubmitBody {
  answers: Answer[];
}

export type {
  SeedQuestion,
  ViewQuestion,
  QuestionResult,
  Answer,
  SeedQuiz,
  ViewQuiz,
  QuizSubmitBody,
}
