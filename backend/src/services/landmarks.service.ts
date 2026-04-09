import * as landmarksRepository from "../repositories/landmarks.repository";
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
  const XP_REWARD = 20;

  const landmark = await landmarksRepository.findLandmark(landmarkId);

  if (!landmark) {
    throw new Error("Landmark not found");
  }

  if (landmark.qr_string !== qrCodeScanned) {
    throw new Error("Invalid landmark QR code");
  }

  const { newVisit, updatedProgress } = await landmarksRepository.createVisitWithXP(studentNum, landmarkId, XP_REWARD);

  if (!newVisit || !updatedProgress) {
    throw new Error("Failed to process scan");
  }

  const achievementsEarned = await checkLandmarkAchievements(studentNum);

  const { qr_string, ...publicData } = landmark; // Exclude qr_string from response

  return {
    message: "Scan and visit successful",
    ...publicData,
    visited_at: newVisit.visited_at,
    xp_earned: XP_REWARD,
    new_total_xp: updatedProgress.total_xp,
    new_achievements: achievementsEarned
  };
}

export {
  fetchLandmarkChecklist,
  fetchLandmark,
  processLandmarkVisit
}
