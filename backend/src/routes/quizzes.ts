import express, { type Request, type Response } from "express";
import { prisma } from "../lib/prisma";
import { authenticateToken } from "../middleware/auth.middleware";
import { number } from "zod";

const router = express.Router();

router.use(authenticateToken);

router.get("/", async (req: Request, res: Response) => {
  try {
    const quizzes = await prisma.quiz.findMany({
      include: { questions: true }
    });
    res.json(quizzes);
  } catch (error) {
    res.json({
      error: "Failed to fetch quizzes"
    })
  }
})

router.get("/:id", async (req: Request, res: Response) => {
  const studentNum = (req as any).user.studentNum;
  const quizId = parseInt(req.params.id as string);

  try {
      const [quiz, studentProgress] = await Promise.all([
        prisma.quiz.findUnique({
          where: { quiz_id: quizId }
        }),

        prisma.progress.findUnique({
          where: { student_number: studentNum },
          select: { total_xp: true }
        })
    ]);

    if (!quiz) {
      return res.status(404).json({
        error: "Quiz not found"
      })
    }

    if ((studentProgress?.total_xp ?? 0) < quiz?.required_xp) {
      res.status(403).json({
        error: "Quiz is locked. You need more XP to unlock it."
      })
    }

    const questions = await prisma.question.findMany({
      where: { quiz_id: quizId }
    })

    res.json({
      ...quiz,
      questions
    });
  } catch (error) {
    res.status(500).json({
      error: "Internal Server Error"
    })
  }
})

router.post("/:id/submit", (req: Request, res: Response) => {
  const studentNum = (req as any).user.studentNum;
  const quizId = parseInt(req.params.id as string);

  const { answers } = req.body;

  try {
    const isAnswered = await prisma.quizSubmission.findUnique({
      where: {
        student_number_quiz_id: {
          student_number: studentNum,
          quiz_id: quizId
        }
      }
    });

    if (isAnswered) {
      return res.status(409).json({
        error: "Quiz is already answered"
      });
    }
    
    const questions = await prisma.question.findMany({
      where: { quiz_id: quizId },
      select: {
        question_text: true,
        correct_idx: true,
        item_points: true
      }
    });

    let totalScore = 0;

    const result = questions.map((question, index) => {
      const isCorrect = question.correct_idx === answers[index];
      if (isCorrect) totalScore += question.item_points;

      return {
        question_text: question.question_text,
        
      }
    })

    for (let i=0; i<questions.length; i++) {
      if (questions[i]?.correct_idx === answers[i]) {
        score += questions[i]?.item_points ?? 0; 
      }
    }

    await prisma.quizSubmission.create({
      data: {
        student_number: studentNum,
        quiz_id: quizId,
        score: score
      }
    })

    return res.status(200).json({
      message: "Quiz submitted successfully",
      score: score,
      questions: 
    })
  }

})
