import { randomUUID } from "node:crypto";
import path from "node:path";
import fs from "node:fs";
import QRCode, { type QRCodeToFileOptions } from "qrcode";
import type { SeedLandmark } from "../src/types/landmarks.types";
import { createFileBaseName, getDirectoryName, readJSON, writeJSON } from "../src/lib/fs-utils";

const __dirname = getDirectoryName(import.meta.url); // Get the folder name that generate-qr.ts is in (/data)
const dataDirectory = path.join(__dirname, "data");

const landmarksJsonPath = path.join(dataDirectory, "landmarks.data.json");
const qrFolderPath = path.join(dataDirectory, "qr-codes"); // Create new folder name for QR codes

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
        const qrString = landmark.qr_string ?? randomUUID();
        const updatedLandmark = { ...landmark, qr_string: qrString };
        const fileName = createFileBaseName(updatedLandmark.name);
        await generateQrImages(fileName, updatedLandmark.qr_string);
        return updatedLandmark;
      }
    ));

    writeJSON(landmarksJsonPath, updatedLandmarksData);
    console.log(`${updatedLandmarksData.length} landmark QRs generated successfully`);
    
    return updatedLandmarksData;
  } catch (error) {
    console.error("Error generating landmark QRs:", error);
  }
}

function generateQrImages(fileName: string, qrString: string) {
  const filePath = path.join(qrFolderPath, `${fileName}.png`);

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

  return QRCode.toFile(filePath, qrString, options); // Create the image file
}

export default updateLandmarksData;
