import { prisma } from "../lib/prisma";
import type { Quiz } from "../../generated/prisma/client";
import type { QuizResult } from "../types/quizzes.types";

async function findQuizzes() {
  return await prisma.quiz.findMany({
    include: { _count: { select: { questions: true } } }
  });
}

async function findQuiz(quizId: number) {
  return await prisma.quiz.findUnique({
    where: { quiz_id: quizId }
  });
}

async function findQuizSubmissions(studentNum: string) {
  return await prisma.quizSubmission.findMany({
    where: { student_number: studentNum }
  });
}

async function findQuizSubmission(studentNum: string, quizId: number) {
  return await prisma.quizSubmission.findUnique({
    where: {
      student_number_quiz_id: {
        student_number: studentNum,
        quiz_id: quizId
      }
    }
  });
}

async function findQuestions(quizId: number) {
  return await prisma.question.findMany({
    where: { quiz_id: quizId }
  });
}

async function findQuestionResponses(studentNum: string, quizId: number) {
  return await prisma.questionResponse.findMany({
    where: {
      student_number: studentNum,
      quiz_id: quizId,
    },
    include: { question: true },
    orderBy: { question_id: "asc" }
  });
}

async function createQuizSubmission(
  studentNum: string,
  quiz: Quiz,
  result: QuizResult,
  xpReward: number,
  newLevel: number
) {
  return await prisma.$transaction(async (tx) => {
    // Save detailed responses for review history
    const submission = await tx.quizSubmission.create({
      data: {
        student_number: studentNum,
        quiz_id: quiz.quiz_id,
        score: result.totalScore,
        is_passed: result.totalScore >= quiz.passing_score,
        question_responses: {
          create: result.breakdown.map((questionResult) => ({
            student: { connect: { student_number: studentNum } },
            question: { connect: { question_id: questionResult.info.question_id } },
            selected_idx: questionResult.performance.your_answer,
            is_correct: questionResult.performance.is_correct
          }))
        }
      }
    });
    
    const updatedProgress = await tx.progress.update({
      where: { student_number: studentNum },
      data: {
        quiz_points: { increment: result.totalScore },
        total_xp: { increment: xpReward },
        level: newLevel
      }
    });

    return { submission, updatedProgress }
  });
}

export {
  findQuizzes,
  findQuiz,
  findQuizSubmissions,
  findQuizSubmission,
  findQuestions,
  findQuestionResponses,
  createQuizSubmission
}
