import express, { type Request, type Response } from "express";
import { prisma } from "../lib/prisma";
import { authenticateToken } from "../middleware/auth.middleware";
import type { Question, QuizSubmitBody, QuestionResult } from "../types/quiz.types";
import { SubmitQuizSchema } from "../schemas/quiz.schema";

const router = express.Router();

// User must be logged in to access these routes
router.use(authenticateToken);

// QUIZZES ROOT ENDPOINT
router.get("/", async (req: Request, res: Response) => {
  try {
    const quizzes = await prisma.quiz.findMany({
      include: { questions: true }
    });
    res.json(quizzes);
  } catch (error) {
    res.json({
      error: "Failed to fetch quizzes"
    });
  }
})

// DETAIL ENDPOINT
router.get("/:id", async (req: Request, res: Response) => {
  const studentNum = (req as any).user.studentNum;
  const quizId = parseInt(req.params.id as string);

  try {
    // Used Promise.all() to parallelize database calls to reduce latency
    const [quiz, studentProgress, answered] = await Promise.all([
      prisma.quiz.findUnique({
        where: { quiz_id: quizId }
      }),

      prisma.progress.findUnique({
        where: { student_number: studentNum },
        select: { total_xp: true }
      }),

      prisma.quizSubmission.findUnique({
        where: { 
          student_number_quiz_id: {
            student_number: studentNum,
            quiz_id: quizId
          },
        }
      })
    ]);

    // Check if quiz exists in the database
    if (!quiz) {
      return res.status(404).json({
        error: "Quiz not found"
      });
    }

    // Checks if the student's current XP is enough to unlock the quiz
    if ((studentProgress?.total_xp ?? 0) < quiz?.required_xp) {
      return res.status(403).json({
        error: "Quiz is locked. You need more XP to unlock it."
      });
    }

    let questions: Question[];
    
    // If the quiz is already taken, include previous answers but keep correct answer hidden to prevent leaking answers to others
    if (answered) {
      const responses = await prisma.questionResponses.findMany({
        where: {
          student_number: studentNum,
          quiz_id: quizId,
        },
        include: { question: true },
        orderBy: { question_id: "asc" }
      });

      questions = responses.map((response) => ({
        question_id: response.question_id,
        question_text: response.question.question_text,
        choices: response.question.choices,
        your_answer: response.selected_idx,
        item_points: response.question.item_points
      }));
    } 
    // If not taken, return the raw questions without the correct answers
    else {
      questions = await prisma.question.findMany({
        where: { quiz_id: quizId },
        select: {
          question_id: true,
          question_text: true,
          choices: true,
          item_points: true
        }
      });
    }

    // The total score is null if never attempted, otherwise return the achieved score
    res.status(200).json({
      ...quiz,
      total_score: answered ? answered.score : null,
      questions
    });
  } catch (error) {
    res.status(500).json({
      error: "Internal Server Error"
    });
  }
})

// SUBMIT ENDPOINT
// <{id: string}, any, QuizSubmitBody> tells TypeScript exactly what to expect in params, response body, and request body respectively
// but mainly, it is used to explicitly type `answers` as Answer[] for Intellisense
router.post("/:id/submit", async (req: Request<{id: string}, any, QuizSubmitBody>, res: Response) => {
  // Validate with zod
  const validation = SubmitQuizSchema.safeParse(req.body);

  if (!validation.success) {
    return res.status(400).json({
      error: "Invalid data format"
    });
  }

  const { answers } = validation.data;
  const studentNum = (req as any).user.studentNum;
  const quizId = parseInt(req.params.id as string);

  try {
    const quiz = await prisma.quiz.findUnique({
      where: { quiz_id: quizId },
      select: { name: true }
    });

    if (!quiz) {
      return res.status(404).json({
        error: "Quiz not found"
      });
    } 

    const isAnswered = await prisma.quizSubmission.findUnique({
      where: {
        student_number_quiz_id: {
          student_number: studentNum,
          quiz_id: quizId
        }
      }
    });

    // Check submission status first to prevent farming points or multiple attempts
    if (isAnswered) {
      return res.status(409).json({
        error: "Quiz already answered"
      });
    }
    
    // Fetch correct answers from database to calculate score
    const questions = await prisma.question.findMany({
      where: { quiz_id: quizId },
      select: {
        question_id: true,
        question_text: true,
        choices: true,
        correct_idx: true,
        item_points: true
      }
    });

    if (answers.length < questions.length) {
      return res.status(400).json({
        error: "All questions must be answered"
      })
    }

    let totalScore = 0;

    const questionResults: QuestionResult[] = answers.map((ans) => {
      const question = questions.find(q => q.question_id === ans.question_id);

      if (!question) throw new Error(`Question ${ans.question_id} not found`);

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

    await prisma.$transaction(async (tx) => {
      // Save detailed responses for review history
      await tx.quizSubmission.create({
        data: {
          student_number: studentNum,
          quiz_id: quizId,
          score: totalScore,
          question_responses: {
            create: questionResults.map((result) => ({
              student: { connect: { student_number: studentNum } },
              question: { connect: { question_id: result.question_id } },
              selected_idx: result.your_answer
            }))
          }
        }
      });

      // Save cumulative quiz points to the student profile
      await tx.progress.update({
        where: { student_number: studentNum },
        data: { quiz_points: { increment: totalScore } }
      })
    });

    res.status(200).json({
      message: "Quiz submitted successfully",
      quiz_name: quiz.name,
      total_score: totalScore,
      result: questionResults
    });
  } catch (error) {
    res.status(500).json({
      error: "Internal Server Error"
    });
  }
})

export default router;
