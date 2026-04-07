import type { SeedAchievement } from "../../src/types/achievements.types";

export const achievementsData: SeedAchievement[] = [
  // EXPLORER TIERS (based on landmark count)
  { 
    title: "Envergan Scout", 
    description: "Your journey begins! Successfully located your first campus landmark.", 
    category: "EXPLORER", 
    threshold: 1 
  },
  { 
    title: "Wildcat Voyager", 
    description: "Becoming a local! You've successfully navigated to 5 landmarks.", 
    category: "EXPLORER", 
    threshold: 5 
  },
  { 
    title: "Luzonian Trailblazer", 
    description: "Campus Master! You've explored every corner of the university.", 
    category: "EXPLORER", 
    threshold: 10 
  },
  
  // SCHOLAR TIERS (Based on quiz points)
  { 
    title: "Envergan Aspirant", 
    description: "50 quiz points achieved.", 
    category: "SCHOLAR", 
    threshold: 50 
  },
  { 
    title: "Wildcat Seeker", 
    description: "100 quiz points achieved.", 
    category: "SCHOLAR", 
    threshold: 100 
  },
  { 
    title: "Luzonian Paragon", 
    description: "150 quiz points achieved. Hawak mo ang beat!", 
    category: "SCHOLAR", 
    threshold: 150 
  }
];
