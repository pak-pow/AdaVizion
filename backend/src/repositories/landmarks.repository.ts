import { prisma } from "../lib/prisma";
import { supabase } from "../lib/supabase";

async function findAllLandmarks() {
  return await prisma.landmark.findMany();
}

async function findOneLandmark() {
  return await prisma.landmark.findFirst();
}

async function findLandmarksCount() {
  return prisma.landmark.count();
}

async function findLandmarksVisitedByStudent(studentNum: string) {
  return await prisma.landmarksVisited.findMany({
    where: { student_number: studentNum }
  });
}

async function findLandmark(landmarkId: number) {
  return prisma.landmark.findUnique({
    where: { landmark_id: landmarkId }
  });
}

async function findLandmarkVisitedByStudent(studentNum: string, landmarkId: number) {
  return prisma.landmarksVisited.findUnique({
    where: {
      student_number_landmark_id: {
        student_number: studentNum,
        landmark_id: landmarkId
      }
    }
  });
}

async function findLandmarkByQr(qrString: string) {
  return prisma.landmark.findUnique({
    where: { qr_string: qrString }
  });
}

async function findLandmarksVisitedCount(studentNum: string) {
  return prisma.landmarksVisited.count({
    where: { student_number: studentNum }
  });
}

async function createLandmarkVisit(
  studentNum: string,
  landmarkId: number,
  xpReward: number,
  newLevel: number
) {
  return await prisma.$transaction(async (tx) => {
    const newVisit = await tx.landmarksVisited.create({
      data: {
        student_number: studentNum,
        landmark_id: landmarkId
      }
    });

    const updatedProgress = await tx.progress.update({
      where: { student_number: studentNum },
      data: {
        total_xp: { increment: xpReward },
        level: newLevel
      }
    });

    return { newVisit, updatedProgress }
  });
}

async function findOneLandmarkThumbnail() {
  return await supabase
    .storage
    .from("landmarks")
    .list("thumbnails", {
      limit: 1,
    });
}

export {
  findAllLandmarks,
  findOneLandmark,
  findLandmarksCount,
  findLandmarksVisitedByStudent,
  findLandmark,
  findLandmarkVisitedByStudent,
  findLandmarkByQr,
  findLandmarksVisitedCount,
  createLandmarkVisit,
  findOneLandmarkThumbnail
}
