import path from "node:path";
import fs from "node:fs";
import type { SeedAchievement } from "../src/types/achievements.types";
import { getDirectoryName, readJSON, writeJSON } from "../src/lib/fs-utils";
import { supabase } from "../src/lib/supabase";

const __dirname = getDirectoryName(import.meta.url);
const dataDirectory = path.join(__dirname, "data");

const achievementsJsonPath = path.join(dataDirectory, "achievements.data.json");
const badgesFolderPath = path.join(dataDirectory, "achievement-badges");

async function updateAchievementsData() {
  try {
    const rawAchievementsData = readJSON(achievementsJsonPath);

    const updatedAchievementsData = await Promise.all(rawAchievementsData.map(
      async (achievement: SeedAchievement) => {
        // Create a sanitized base file name for landmark thumbnail and QR code files
        const baseName = `${achievement.category.toLowerCase()}-level-${achievement.tier}`;

        // Get the URL of the new uploaded thumbnail
        const publicUrl = await uploadBadge(baseName);

        const updatedAchievement = {
          ...achievement,
          img_path: publicUrl
        };

        return updatedAchievement;
      }
    ));

    // Overwrite the JSON file
    writeJSON(achievementsJsonPath, updatedAchievementsData);
    console.log(`${updatedAchievementsData.length} achievement data updated successfully`);
    
    return updatedAchievementsData;
  } catch (error) {
    console.error("Error updating achievements data:", error);
  }
}

async function uploadBadge(baseName: string) {
  try {
    // Construct the full file name with extension
    const fileName = `${baseName}.png`;

    // Construct the file path to the badge file
    const filePath = path.join(badgesFolderPath, fileName);

    if (!fs.existsSync(filePath)) {
      console.warn(`File not found: ${filePath}`);
      return;
    }

    // File content
    const fileBuffer = fs.readFileSync(filePath); 

    // Upload the file
    const { error } = await supabase
      .storage
      .from("achievement-badges")
      .upload(fileName, fileBuffer, {
        contentType: "image/png",
        upsert: true,
      });
    
    if (error) {
      throw new Error("Failed to upload file to Supabase");
    };

    // Get the URL
    const { data } = supabase
      .storage
      .from("achievement-badges")
      .getPublicUrl(fileName);

    if (!data) {
      throw new Error("Achievement badge not found");
    }

    return data.publicUrl;
  } catch (error) {
    console.error("Error uploading achievement badge:", error);
  }
}

export default updateAchievementsData;
