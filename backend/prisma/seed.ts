import type { Prisma } from "../generated/prisma/client";
import { prisma } from "../src/lib/prisma";
import { landmarksData } from "./data/landmarks.data";
import { quizzesData } from "./data/quizzes.data";
import { achievementsData } from "./data/achievements.data";

async function main() {
  await seedLandmarks();
  await seedQuizzes();
  await seedAchievements();
}

async function seedLandmarks() {
  console.log("Seeding landmarks...");

  for (const landmark of landmarksData) {
    await prisma.landmark.upsert({
      where: { qr_string: landmark.qr_string },
      update: {
        name: landmark.name,
        description: landmark.description,
        fun_fact: landmark.fun_fact,
        img_path: landmark.img_path
      },
      create: {
        name: landmark.name,
        description: landmark.description,
        fun_fact: landmark.fun_fact,
        qr_string: landmark.qr_string,
        img_path: landmark.img_path
      }
    })
  }

  console.log(`${landmarksData.length} landmarks seeded successfully`);
}

async function seedQuizzes() {
  console.log("Seeding quizzes and questions...");

  for (const quiz of quizzesData) {
    const maxPoints = quiz.questions.reduce((sum, question) => sum + question.item_points, 0);

    const passingPercent = 0.75;
    const passingScore = Math.ceil(maxPoints * passingPercent);

    const questionData = quiz.questions.map((question) => ({
      question_text: question.question_text,
      choices: question.choices as Prisma.InputJsonValue,
      correct_idx: question.correct_idx,
      item_points: question.item_points
    }))

    await prisma.quiz.upsert({
      where: { name: quiz.name },
      update: {
        min_landmarks: quiz.min_landmarks,
        max_score: maxPoints,
        passing_score: passingScore,
        questions: {
          deleteMany: {},
          create: questionData
        }
      },
      create: {
        name: quiz.name,
        min_landmarks: quiz.min_landmarks,
        max_score: maxPoints,
        passing_score: passingScore,
        questions: {
          create: questionData
        }
      }
    })
  }

  console.log(`${quizzesData.length} quizzes seeded successfully`);
}

async function seedAchievements() {
  console.log("Seeding achievements...");

  for (const achievement of achievementsData) {
    await prisma.achievement.upsert({
      where: { title: achievement.title },
      update: {
        description: achievement.description,
        category: achievement.category,
        threshold: achievement.threshold
      },
      create: achievement
    })
  }

  console.log(`${achievementsData.length} achievements seeded successfully`);
}

main()
  .then(() => {
    console.log("Database seeded successfully");
  })
  .catch((error) => {
    console.error("Error seeding database:", error);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
