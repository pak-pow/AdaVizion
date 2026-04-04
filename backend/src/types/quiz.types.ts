import type { JsonValue } from "@prisma/client/runtime/client";

interface Question {
  question_id: number;
  question_text: string;
  choices: JsonValue;
  your_answer?: number;
  item_points: number;
}

interface Answer {
  question_id: number;
  selected_idx: number;
}

interface QuizSubmitBody {
  answers: Answer[];
}

interface QuestionResult {
  question_id: number;
  question_text: string;
  choices: any;
  your_answer: number;
  correct_answer: number;
  is_correct: boolean;
  item_points: number;
  points_earned: number;
}

export type {
  Question,
  Answer,
  QuizSubmitBody,
  QuestionResult
}
