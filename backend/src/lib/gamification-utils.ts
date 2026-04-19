import { GAMIFICATION_CONFIG } from "../constants/gamification-config";

//  Derives the level based on the student's total xp
function calculateNewLevel(xpReward: number, currentTotalXP: number) {
  const newTotalXP = currentTotalXP + xpReward;

  // This is the formula for calculating the level
  return Math.floor(newTotalXP / GAMIFICATION_CONFIG.XP_PER_LEVEL) + 1;
}

// Calculates distance and thresholds for the next level milestone
// Mainly for the frontend, ily guys :)
function calculateXpProgress(
  newLevel: number,
  newTotalXP: number
) {
  // The threshold represents the XP required to reach the next level
  const nextXpThreshold = (newLevel + 1) * GAMIFICATION_CONFIG.XP_PER_LEVEL;
  const xpToNextLevel = nextXpThreshold - newTotalXP;

  return {
    next_threshold: nextXpThreshold,
    to_next_level: xpToNextLevel
  }
}

export {
  calculateNewLevel,
  calculateXpProgress
}
