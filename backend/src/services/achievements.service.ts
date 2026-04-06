import { prisma } from "../lib/prisma";
import type { AchievementCategory } from "../../generated/prisma/enums"
import type { Achievement } from "../../generated/prisma/client";

async function getEligibleAchievements(
  studentNum: string,
  category: AchievementCategory,
  metric: number
) {
  const eligibleAchievements = await prisma.achievement.findMany({
    where: {
      category: category,
      threshold: { lte: metric },
      earners: {
        none: { student_number: studentNum }
      }
    }
  });

  return eligibleAchievements;
}

async function awardAchievements(studentNum: string, eligibleAchievements: Achievement[]) {
  if (eligibleAchievements.length > 0) {
    await prisma.achievementsEarned.createMany({
      data: eligibleAchievements.map((achievement) => ({
        student_number: studentNum,
        achievement_id: achievement.achievement_id
      }))
    });
  }
}

async function checkLandmarkAchievements(studentNum: string)  {
  const visitCount = await prisma.landmarksVisited.count({
    where: { student_number: studentNum }
  });

  if (visitCount === 0) return [];

  const eligibleAchievements = await getEligibleAchievements(studentNum, "EXPLORER", visitCount);

  await awardAchievements(studentNum, eligibleAchievements);

  return eligibleAchievements;
}

async function checkQuizAchievements(studentNum: string) {
  const studentProgress = await prisma.progress.findUnique({
    where: { student_number: studentNum },
    select: { quiz_points: true }
  });

  const quizPoints = studentProgress?.quiz_points || 0;

  const eligibleAchievements = await getEligibleAchievements(studentNum, "SCHOLAR", quizPoints);

  await awardAchievements(studentNum, eligibleAchievements);

  return eligibleAchievements;
}

export {
  getEligibleAchievements,
  awardAchievements,
  checkLandmarkAchievements,
  checkQuizAchievements
}
