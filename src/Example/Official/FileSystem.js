import fs from "node:fs";

export const removeTree = (targetPath) => () => {
  fs.rmSync(targetPath, { recursive: true, force: true });
};
