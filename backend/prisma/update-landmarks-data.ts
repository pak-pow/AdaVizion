import { randomUUID } from "node:crypto";
import path from "node:path";
import fs from "node:fs";
import QRCode, { type QRCodeToFileOptions } from "qrcode";
import type { SeedLandmark } from "../src/types/landmarks.types";
import { createFileBaseName, getDirectoryName, readJSON, writeJSON } from "../src/lib/fs-utils";
import { supabase } from "../src/lib/supabase";

const __dirname = getDirectoryName(import.meta.url); // Get the folder name that generate-qr.ts is in (/data)
const dataDirectory = path.join(__dirname, "data");

const landmarksJsonPath = path.join(dataDirectory, "landmarks.data.json");
const qrFolderPath = path.join(dataDirectory, "qr-codes");
const thumbnailFolderPath = path.join(dataDirectory, "landmark-thumbnails");

function prepareImageDirectory() {
  if (fs.existsSync(qrFolderPath)) {
    fs.rmSync(qrFolderPath, { recursive: true }); // Remove /qr-codes if the directory exists
  }

  fs.mkdirSync(qrFolderPath, { recursive: true }); // Create a new folder named qr-codes in /data
}

async function updateLandmarksData() {
  try {
    const rawLandmarksData = readJSON(landmarksJsonPath);

    prepareImageDirectory();

    const updatedLandmarksData = await Promise.all(rawLandmarksData.map(
      async (landmark: SeedLandmark) => {
        // Create a sanitized base file name for landmark thumbnail and QR code files
        const baseName = createFileBaseName(landmark.name);

        // Use existing qr_string. Otherwise, generate a new one.
        const qrString = landmark.qr_string ?? randomUUID();

        // Get the URL of the new uploaded thumbnail
        const publicUrl = await uploadThumbnail(baseName, qrString);

        const updatedLandmark = {
          ...landmark,
          qr_string: qrString,
          img_path: publicUrl
        };

        await generateQrImage(baseName, updatedLandmark.qr_string);

        return updatedLandmark;
      }
    ));

    // Overwrite the JSON file
    writeJSON(landmarksJsonPath, updatedLandmarksData);
    console.log(`${updatedLandmarksData.length} landmark QRs generated successfully`);
    
    return updatedLandmarksData;
  } catch (error) {
    console.error("Error updating landmarks data:", error);
  }
}

function generateQrImage(baseName: string, qrString: string) {
  try {
    // Construct the file path to the thumbnail file
    const filePath = path.join(qrFolderPath, `${baseName}.png`);

    // QR code config
    const options: QRCodeToFileOptions = {
      errorCorrectionLevel: 'H',
      type: "png",
      margin: 1,
      color: {
        dark: '#000000',
        light: '#FFFFFF'
      }
    }

    // Create the file
    return QRCode.toFile(filePath, qrString, options);
  } catch (error) {
    console.error("Error generating QR image:", error);
    return null;
  }
}

async function uploadThumbnail(baseName: string, qrString: string) {
  try {
    // Construct the file path to the thumbnail file
    const filePath = path.join(thumbnailFolderPath, `${baseName}.jpg`);

    if (!fs.existsSync(filePath)) {
      console.warn(`File not found: ${filePath}`);
      return;
    }

    // File content
    const fileBuffer = fs.readFileSync(filePath); 

    // Name of folder in the file bucket
    const folderName = "thumbnails";

    // New name for the file to be uploaded
    const newFileName = `${folderName}/${baseName}-${qrString}.jpg`;

    // Upload the file
    const { error } = await supabase
      .storage
      .from("landmarks")
      .upload(newFileName, fileBuffer, {
        contentType: "image/jpeg",
        upsert: true,
      });
    
    if (error) {
      throw new Error("Failed to upload file to Supabase");
    };

    // Get the URL
    const { data } = supabase
      .storage
      .from("landmarks")
      .getPublicUrl(newFileName);

    if (!data) {
      throw new Error("Landmark thumbnail not found");
    }

    return data.publicUrl;
  } catch (error) {
    console.error("Error uploading landmark thumbnail:", error);
  }
}

export default updateLandmarksData;
