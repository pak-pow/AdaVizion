import { prisma } from "../lib/prisma";

async function findAllLandmarks() {
  return await prisma.landmark.findMany();
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

async function findLandmarksVisitedCount(studentNum: string) {
  return prisma.landmarksVisited.count({
    where: { student_number: studentNum }
  });
}

async function createVisitWithXP(studentNum: string, landmarkId: number, XP_REWARD: number) {
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
        total_xp: {
          increment: XP_REWARD
        }
      }
    });

    return { newVisit, updatedProgress }
  });
}

export {
  findAllLandmarks,
  findLandmarksVisitedByStudent,
  findLandmark,
  findLandmarkVisitedByStudent,
  findLandmarksVisitedCount,
  createVisitWithXP
}
