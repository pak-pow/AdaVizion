import fs from "node:fs";
import { fileURLToPath } from 'node:url';
import { dirname } from "node:path";

function getFileName(importMetaUrl: ImportMeta["url"]) {
  return fileURLToPath(importMetaUrl); // Get the name of the current file
}

function getDirectoryName(importMetaUrl: ImportMeta["url"]) {
  const __filename = getFileName(importMetaUrl);
  return dirname(__filename); // Get the folder name of the current file
}

function readJSON(jsonFilePath: string) {
  const stringJSON = fs.readFileSync(jsonFilePath, "utf-8");
  return JSON.parse(stringJSON); // Transform string JSON into a JavaScript object
}

function writeJSON(jsonFilePath: string, data: any) {
  const stringJSON = JSON.stringify(data, null, 2);
  fs.writeFileSync(jsonFilePath, stringJSON, "utf-8"); // Overwrite the JSON file
}

export {
  getFileName,
  getDirectoryName,
  readJSON,
  writeJSON
}
