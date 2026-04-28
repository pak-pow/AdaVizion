import type { Achievement } from "../../generated/prisma/client"

type SeedAchievement = Omit<Achievement, "achievement_id" | "created_at" | "updated_at">;

export type {
  SeedAchievement
}
