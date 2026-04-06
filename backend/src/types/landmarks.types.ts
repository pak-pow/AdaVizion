import type { Landmark } from "../../generated/prisma/client";

type SeedLandmark = Omit<Landmark, "landmark_id" | "created_at">

type ViewLandmark = Omit<Landmark, "qr_string">

interface LandmarkVisitBody {
  qr_code_scanned: string;
}

export type {
  SeedLandmark,
  ViewLandmark,
  LandmarkVisitBody
}
