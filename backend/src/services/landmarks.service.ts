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

    return {
      landmark_id: landmark.landmark_id,
      name: landmark.name,
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

  return { landmark, visit };
}

async function processLandmarkVisit(
  studentNum: string,
  landmarkId: number,
  qrCodeScanned: string
) {
  const XP_REWARD = 20;

  const [landmark, visit] = await Promise.all([
    landmarksRepository.findLandmark(landmarkId),
    landmarksRepository.findLandmarkVisitedByStudent(studentNum, landmarkId)
  ]);

  if (!landmark) {
    throw new Error("Landmark not found");
  }

  if (visit) {
    throw new Error("Landmark already visited");
  }

  if (landmark.qr_string !== qrCodeScanned) {
    throw new Error("Invalid landmark QR code");
  }

  const { newVisit, updatedProgress } = await landmarksRepository.createVisitWithXP(studentNum, landmarkId, XP_REWARD);

  if (!newVisit || !updatedProgress) {
    throw new Error("Failed to process scan");
  }

  const achievementsEarned = await checkLandmarkAchievements(studentNum);

  return {
    landmark,
    newVisit,
    updatedProgress,
    XP_REWARD,
    achievementsEarned
  };
}

export {
  fetchLandmarkChecklist,
  fetchLandmark,
  processLandmarkVisit
}
