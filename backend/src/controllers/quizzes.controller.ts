import type { Request, Response } from "express";
import * as quizzesService from "../services/quizzes.service";
import { SubmitQuizSchema } from "../schemas/quizzes.schema";
import { handleControllerError } from "../lib/error-handler";

async function getQuizzes(req: Request, res: Response) {
  try {
    const studentNum = (req as any).user.studentNum;
    const quizList = await quizzesService.fetchQuizzes(studentNum);

    return res.status(200).json(quizList);
  } catch (error: any) {
    return handleControllerError(res, error, "QUIZ");
  }
}

async function getQuiz(req: Request, res: Response) {
  try {
    const studentNum = (req as any).user.studentNum;
    const quizId = parseInt(req.params.id as string);

    const quiz = await quizzesService.fetchQuiz(studentNum, quizId);

    // The total score is null if never attempted, otherwise return the achieved score
    return res.status(200).json(quiz);
  } catch (error: any) {
    return handleControllerError(res, error, "QUIZ");
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

    const submissionDetails = await quizzesService.processQuizSubmission(studentNum, quizId, answers);

    return res.status(200).json(submissionDetails);
  } catch (error: any) {
    return handleControllerError(res, error, "QUIZ");
  }
}

export {
  getQuizzes,
  getQuiz,
  submitQuiz
}
