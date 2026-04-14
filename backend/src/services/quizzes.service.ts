import * as quizzesRepository from "../repositories/quizzes.repository";
import * as landmarksRepository from "../repositories/landmarks.repository";
import type { Answer, ViewQuestion } from "../types/quizzes.types";
import type { Achievement, Question } from "../../generated/prisma/client";
import { checkQuizAchievements } from "./achievements.service";

async function fetchQuizzes(studentNum: string) {
  const [allQuizzes, quizSubmissions, landmarksVisitedCount] = await Promise.all([
    quizzesRepository.findQuizzes(),
    quizzesRepository.findQuizSubmissions(studentNum),
    landmarksRepository.findLandmarksVisitedCount(studentNum)
  ]);

  const submissionDetails = new Map(quizSubmissions.map((s) => [
    s.quiz_id, { score: s.score, is_passed: s.is_passed }
  ]));

  // Final list of quizzes to show on the frontend
  const quizList = allQuizzes.map((quiz) => {
    const { _count, ...mainQuizDetails } = quiz;
    const submission = submissionDetails.get(quiz.quiz_id);
    const isLocked = quiz.min_landmarks > landmarksVisitedCount;

    return {
      ...mainQuizDetails,
      question_count: _count.questions,
      is_locked: isLocked,
      remaining_landmarks_needed: Math.max(0, quiz.min_landmarks - landmarksVisitedCount),
      is_completed: !!submission,
      score_achieved: submission ? submission.score : null,
      is_passed: submission ? submission.is_passed : false
    }
  });

  return quizList;
}

async function fetchQuiz(studentNum: string, quizId: number) {
  const [quiz, answered, landmarksVisitedCount] = await Promise.all([
    quizzesRepository.findQuiz(quizId),
    quizzesRepository.findQuizSubmission(studentNum, quizId),
    landmarksRepository.findLandmarksVisitedCount(studentNum)
  ]);

  if (!quiz) {
    throw new Error("Quiz not found");
  }

  // Checks if the student's current XP is enough to unlock the quiz
  const isLocked = quiz.min_landmarks > landmarksVisitedCount;

  if (isLocked) {
    throw new Error("Quiz requires more landmark visits to unlock");
  }

  let questions: ViewQuestion[] = await quizzesRepository.findQuestions(quizId);

  // If the quiz is already taken, include previous answers but keep correct answer hidden to prevent leaking answers to others
  if (answered) {
    const responses = await quizzesRepository.findQuestionResponses(studentNum, quizId);

    console.log(responses);

    questions = responses.map((response) => ({
      question_id: response.question_id,
      quiz_id: response.quiz_id,
      question_text: response.question.question_text,
      choices: response.question.choices,
      your_answer: response.selected_idx,
      item_points: response.question.item_points,
    }));
  } 
  // If not taken, return the raw questions without the correct answers
  else {
    questions = questions.map(({ correct_idx, ...publicData }) => publicData);
  }

  return {
    ...quiz,
    is_locked: isLocked,
    is_completed: !!answered,
    is_passed: answered?.is_passed ?? false,
    score_achieved: answered?.score ?? null,
    remaining_landmarks_needed: Math.max(0, quiz.min_landmarks - landmarksVisitedCount),
    questions
  };
}

async function evaluateQuestionResponses(questions: Question[], answers: Answer[]) {
  let totalScore = 0;

  const breakdown = answers.map((ans) => {
    const question = questions.find(q => q.question_id === ans.question_id);

    if (!question) {
      throw new Error("Invalid question ID");
    }

    const isCorrect = question.correct_idx === ans.selected_idx;

    // Add the amount of points the question is worth to the total score
    if (isCorrect) totalScore += question.item_points;

    return {
      question_id: question.question_id,
      question_text: question.question_text,
      choices: question.choices,
      your_answer: ans.selected_idx,
      correct_answer: question.correct_idx,
      is_correct: isCorrect,
      item_points: question.item_points,
      points_earned: isCorrect ? question.item_points : 0
    };
  })

  return {
    totalScore,
    breakdown
  }
} 

async function processQuizSubmission(studentNum: string, quizId: number, answers: Answer[]) {
  const [quiz, questions] = await Promise.all([
    quizzesRepository.findQuiz(quizId),
    quizzesRepository.findQuestions(quizId)
  ]);

  if (!quiz) {
    throw new Error("Quiz not found");
  }

  if (answers.length !== questions.length) {
    throw new Error("Answer count does not match question count");
  }

  const result = await evaluateQuestionResponses(questions, answers);
  
  if (!result) {
    throw new Error("Error evaluating quiz answers");
  }

  const { submission, updatedProgress } = await quizzesRepository.createQuizSubmission(
    studentNum,
    quiz,
    result
  );

  if (!submission || !updatedProgress) {
    throw new Error("Database transaction failed to return new quiz submission and updated progress");
  }

  let achievementsEarned: Achievement[] = [];

  if (submission.is_passed) {
    achievementsEarned = await checkQuizAchievements(studentNum);
  }
  
  return {
    message: "Quiz submitted successfully",
    ...quiz,
    score_achieved: result.totalScore,
    is_passed: submission.is_passed,
    completed_at: submission.completed_at,
    new_total_quiz_points: updatedProgress.quiz_points,
    result: result.breakdown,
    new_achievements: achievementsEarned
  };
}

export {
  fetchQuizzes,
  fetchQuiz,
  processQuizSubmission
}
