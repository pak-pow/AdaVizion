import { prisma } from "../lib/prisma";
import type { AchievementCategory } from "../../generated/prisma/enums"

async function findAchievements() {
  return await prisma.achievement.findMany();
}

async function findAchievementsEarned(studentNum: string) {
  return await prisma.achievementsEarned.findMany({
    where: { student_number: studentNum }
  });
}

async function findEligibleAchievements(
  studentNum: string,
  category: AchievementCategory,
  metric: number
) {
  return await prisma.achievement.findMany({
    where: {
      category: category,
      threshold: { lte: metric },
      earners: {
        none: { student_number: studentNum }
      }
    }
  });
}

async function createAchievementsEarned(
  studentNum: string,
  eligibleAchievemntsId: number[]
) {
  return await prisma.achievementsEarned.createMany({
    data: eligibleAchievemntsId.map((achievementId) => ({
      student_number: studentNum,
      achievement_id: achievementId
    }))
  });
}

export {
  findAchievements,
  findAchievementsEarned,
  findEligibleAchievements,
  createAchievementsEarned
}
