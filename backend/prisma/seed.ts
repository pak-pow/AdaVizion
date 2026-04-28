import type { Prisma } from "../generated/prisma/client";
import { prisma } from "../src/lib/prisma";
import path from "node:path";
import { getDirectoryName, readJSON } from "../src/lib/fs-utils";
import type { SeedQuiz } from "../src/types/quizzes.types";
import type { SeedAchievement } from "../src/types/achievements.types";
import type { SeedLandmark } from "../src/types/landmarks.types";
import updateLandmarksData from "./update-landmarks-data";
import updateAchievementsData from "./update-achievements-data";

const __dirname = getDirectoryName(import.meta.url);
const dataDirectory = path.join(__dirname, "data");

async function main() {
  try {
    await seedLandmarks();
    await seedQuizzes();
    await seedAchievements();
    console.log("Database seeded successfully");
  } catch (error) {
    console.error("Error seeding database:", error);
  } finally {
    await prisma.$disconnect();
  }  
}

async function seedLandmarks() {
  await updateLandmarksData();

  console.log("Seeding landmarks...");

  const landmarksJsonFilePath = path.join(dataDirectory, "landmarks.data.json");
  const landmarksData: SeedLandmark[] = readJSON(landmarksJsonFilePath);

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

  const quizzesJsonFilePath = path.join(dataDirectory, "quizzes.data.json");
  const quizzesData: SeedQuiz[] = readJSON(quizzesJsonFilePath);

  for (const quiz of quizzesData) {
    const maxPoints = quiz.questions.reduce((sum, question) => sum + question.item_points, 0);

    const passingPercent = 0.70;
    const passingScore = Math.ceil(maxPoints * passingPercent);

    const upsertedQuiz = await prisma.quiz.upsert({
      where: { name: quiz.name },
      update: {
        min_landmarks: quiz.min_landmarks,
        max_score: maxPoints,
        passing_score: passingScore,
      },
      create: {
        name: quiz.name,
        min_landmarks: quiz.min_landmarks,
        max_score: maxPoints,
        passing_score: passingScore,
      }
    });

    for (const question of quiz.questions) {
      await prisma.question.upsert({
        where: {  
          quiz_id: upsertedQuiz.quiz_id,
          question_text: question.question_text
         },
        update: {
          choices: question.choices as Prisma.InputJsonValue,
          correct_idx: question.correct_idx,
          item_points: question.item_points
        },
        create: {
          quiz_id: upsertedQuiz.quiz_id,
          question_text: question.question_text,
          choices: question.choices as Prisma.InputJsonValue,
          correct_idx: question.correct_idx,
          item_points: question.item_points
        }
      });
    }
  }

  console.log(`${quizzesData.length} quizzes seeded successfully`);
}

async function seedAchievements() {
  await updateAchievementsData();

  console.log("Seeding achievements...");

  const achievementsJsonFilePath = path.join(dataDirectory, "achievements.data.json");
  const achievementsData: SeedAchievement[] = readJSON(achievementsJsonFilePath);

  for (const achievement of achievementsData) {
    await prisma.achievement.upsert({
      where: { title: achievement.title },
      update: {
        description: achievement.description,
        category: achievement.category,
        threshold: achievement.threshold,
        tier: achievement.tier,
        img_path: achievement.img_path
      },
      create: achievement
    })
  }

  console.log(`${achievementsData.length} achievements seeded successfully`);
}

main();
