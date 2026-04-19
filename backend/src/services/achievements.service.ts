import * as achievementsRepository from "../repositories/achievements.repository";
import * as landmarksRepository from "../repositories/landmarks.repository";
import * as studentsRepository from "../repositories/students.repository";
import type { Achievement } from "../../generated/prisma/client";

async function fetchAchievementsList(studentNum: string) {
  const [allAchievements, achievementsEarned] = await Promise.all([
    achievementsRepository.findAchievements(),
    achievementsRepository.findAchievementsEarned(studentNum)
  ]);

  const earnedAtMap = new Map(
    achievementsEarned.map((achievement) => [achievement.achievement_id, achievement.earned_at])
  );

  // Final list to show on the frontend
  return allAchievements.map((achievement) => {
    const earnedAt = earnedAtMap.get(achievement.achievement_id);

    return {
      ...achievement,
      is_unlocked: !!earnedAt, // Flag for frontend to visually display unlocked status
      earned_at: earnedAt || null
    }
  });
}

async function awardAchievements(
  studentNum: string,
  eligibleAchievements: Achievement[]
) {
  const eligibleAchievemntsId = eligibleAchievements.map((achievement) => achievement.achievement_id);

  if (eligibleAchievements.length > 0) {
    await achievementsRepository.createAchievementsEarned(studentNum, eligibleAchievemntsId);
  }
}

async function checkLandmarkAchievements(studentNum: string)  {
  const visitCount = await landmarksRepository.findLandmarksVisitedCount(studentNum);

  const eligibleAchievements = await achievementsRepository.findEligibleAchievements(studentNum, "EXPLORER", visitCount);

  await awardAchievements(studentNum, eligibleAchievements);

  return eligibleAchievements;
}

async function checkQuizAchievements(studentNum: string) {
  const studentProgress = await studentsRepository.findStudentProgress(studentNum);

  const quizPoints = studentProgress?.quiz_points || 0;

  const eligibleAchievements = await achievementsRepository.findEligibleAchievements(studentNum, "SCHOLAR", quizPoints);

  await awardAchievements(studentNum, eligibleAchievements);

  return eligibleAchievements;
}

export {
  fetchAchievementsList,
  awardAchievements,
  checkLandmarkAchievements,
  checkQuizAchievements
}
