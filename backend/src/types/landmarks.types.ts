interface BaseLandmark {
  name: string;
  description: string | null;
  fun_fact: string | null;
}

interface SeedLandmark extends BaseLandmark {
  qr_string: string;
}

interface ViewLandmark extends BaseLandmark {
  landmark_id: number;
}

interface LandmarkVisitBody {
  qr_code_scanned: string;
}

export type {
  SeedLandmark,
  ViewLandmark,
  LandmarkVisitBody
}
