import type { Request, Response } from "express";
import * as quizzesService from "../services/quizzes.service";
import { SubmitQuizSchema } from "../schemas/quizzes.schema";
import { QUIZ_ERRORS } from "../constants/error-maps";
import { handleControllerError } from "../lib/error-handler";

async function getQuizzes(req: Request, res: Response) {
  try {
    const studentNum = (req as any).user.studentNum;
    const quizList = quizzesService.fetchQuizzes(studentNum);

    return res.status(200).json(quizList);
  } catch (error: any) {
    return handleControllerError(res, error, QUIZ_ERRORS);
  }
}

async function getQuiz(req: Request, res: Response) {
  try {
    const studentNum = (req as any).user.studentNum;
    const quizId = parseInt(req.params.id as string);

    const {
      quiz,
      answered,
      questions
    } = await quizzesService.fetchQuiz(studentNum, quizId);

    // The total score is null if never attempted, otherwise return the achieved score
    return res.status(200).json({
      ...quiz,
      total_score: answered ? answered.score : null,
      questions
    });
  } catch (error: any) {
    return handleControllerError(res, error, QUIZ_ERRORS);
  }
}

async function submitQuiz(req: Request, res: Response) {
  try {
    const validation = SubmitQuizSchema.safeParse(req.body);

    if (!validation.success) {
      return res.status(400).json({
        error: validation.error?.issues[0]?.message
      });
    }

    const { answers } = validation.data;
    const studentNum = (req as any).user.studentNum;
    const quizId = parseInt(req.params.id as string);

    const {
      quiz,
      result,
      submission,
      updatedProgress,
      achievementsEarned
    } = await quizzesService.processQuizSubmission(studentNum, quizId, answers);

    return res.status(200).json({
      message: "Quiz submitted successfully",
      ...quiz,
      total_score: result.totalScore,
      is_passed: submission.is_passed,
      completed_at: submission.completed_at,
      new_total_quiz_points: updatedProgress.quiz_points,
      result: result.breakdown,
      new_achievements: achievementsEarned
    });
  } catch (error: any) {
    return handleControllerError(res, error, QUIZ_ERRORS);
  }
}

export {
  getQuizzes,
  getQuiz,
  submitQuiz
}
