import { findOneLandmark, findOneLandmarkThumbnail } from "../repositories/landmarks.repository";

async function checkPrisma() {
  try {
    await findOneLandmark();
  } catch (error) {
    throw new Error("Prisma health check failed");
  }
}

async function checkSupabase() {
  const { data, error } = await findOneLandmarkThumbnail();

  if (error) throw new Error("Supabase Storage health check failed");
}

export {
  checkPrisma,
  checkSupabase
}
