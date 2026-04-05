import type { SeedQuiz } from "../../src/types/quiz.types";

export const quizzes: SeedQuiz[] = [
  {
    name: "", 
    required_xp: 0, 
    questions: [
      {
        question_text: "",
        choices: [],
        item_points: 0, 
        correct_idx: 0 // zero-indexed because it references the index of the correct answer in choices
      }
    ]
  }
];
