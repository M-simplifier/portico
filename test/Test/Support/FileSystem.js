import fs from "node:fs";

export const pathExists = (filePath) => () => fs.existsSync(filePath);

export const readTextFile = (filePath) => () =>
  fs.readFileSync(filePath, "utf8");

export const removeTree = (targetPath) => () => {
  fs.rmSync(targetPath, { recursive: true, force: true });
};
