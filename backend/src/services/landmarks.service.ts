import { GAMIFICATION_CONFIG } from "../constants/gamification-config";
import { calculateXpProgress, calculateNewLevel } from "../lib/gamification-utils";
import * as landmarksRepository from "../repositories/landmarks.repository";
import * as studentsRepository from "../repositories/students.repository";
import { checkLandmarkAchievements } from "./achievements.service";

async function fetchLandmarkChecklist(studentNum: string) {
  const [allLandmarks, visitedLandmarks] = await Promise.all([
    landmarksRepository.findAllLandmarks(),
    landmarksRepository.findLandmarksVisitedByStudent(studentNum)
  ]);

  const visitedIds = new Set(visitedLandmarks.map((v) => v.landmark_id));

  // Final checklist to show on the frontend
  const landmarkList = allLandmarks.map((landmark) => {
    const isVisited = visitedIds.has(landmark.landmark_id);
    const { fun_fact, qr_string, ...publicData } = landmark;

    return {
      ...publicData,
      is_visited: isVisited // Flag for frontend to visually display visited status
    };
  });

  return landmarkList;
}

async function fetchLandmark(studentNum: string, landmarkId: number) {
  const [landmark, visit] = await Promise.all([
    landmarksRepository.findLandmark(landmarkId),
    landmarksRepository.findLandmarkVisitedByStudent(studentNum, landmarkId)
  ]);

  if (!landmark) {
    throw new Error("Landmark not found");
  }

  const { qr_string, ...publicData } = landmark;

  if (!visit) {
    const { fun_fact, ...lockedData } = publicData;
    
    return {
      ...lockedData,
      is_unlocked: false,
    };
  }

  return {
    ...publicData,
    is_unlocked: true,
  };
}

async function processLandmarkVisit(
  studentNum: string,
  landmarkId: number,
  qrCodeScanned: string
) {
  const [ landmark, studentProgress ] = await Promise.all([
    landmarksRepository.findLandmark(landmarkId),
    studentsRepository.findStudentProgress(studentNum)
  ]);

  if (!landmark) {
    throw new Error("Landmark not found");
  }

  if (!studentProgress) {
    throw new Error("Student progress does not exist");
  }

  if (landmark.qr_string !== qrCodeScanned) {
    throw new Error("Invalid landmark QR code");
  }

  const xpReward = GAMIFICATION_CONFIG.XP_REWARDS.LANDMARK_VISIT;
  const newLevel = calculateNewLevel(xpReward, studentProgress.total_xp);

  const { newVisit, updatedProgress } = await landmarksRepository.createLandmarkVisit(
    studentNum,
    landmarkId,
    xpReward,
    newLevel
  );

  if (!newVisit || !updatedProgress) {
    throw new Error("Failed to process scan");
  }

  const xpProgress = calculateXpProgress(newLevel, updatedProgress.total_xp);

  const achievementsEarned = await checkLandmarkAchievements(studentNum);

  const { qr_string, ...publicData } = landmark; // Exclude qr_string from response

  return {
    message: "Scan and visit successful",
    ...publicData,
    visited_at: newVisit.visited_at,
    progress: {
      xp: {
        previous: studentProgress.total_xp,
        current: updatedProgress.total_xp,
        earned: xpReward,
        ...xpProgress
      },
      level: {
        previous: studentProgress.level,
        current: newLevel,
        did_level_up: newLevel > studentProgress.level
      }
    },
    new_achievements: achievementsEarned
  };
}

export {
  fetchLandmarkChecklist,
  fetchLandmark,
  processLandmarkVisit
}
