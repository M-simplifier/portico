import { mkdirSync } from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawn } from "node:child_process";

function npxCommand() {
  return process.platform === "win32" ? "npx.cmd" : "npx";
}

function ensureDirectory(directoryPath) {
  mkdirSync(directoryPath, { recursive: true });
}

function main() {
  const homeDirectory = path.join(os.tmpdir(), "portico-spago-home");
  const cacheDirectory = path.join(homeDirectory, ".cache");

  ensureDirectory(homeDirectory);
  ensureDirectory(cacheDirectory);

  const child = spawn(npxCommand(), ["spago", ...process.argv.slice(2)], {
    cwd: process.cwd(),
    env: {
      ...process.env,
      HOME: homeDirectory,
      XDG_CACHE_HOME: cacheDirectory
    },
    stdio: "inherit"
  });

  child.on("exit", (code) => {
    process.exitCode = code ?? 1;
  });

  child.on("error", (error) => {
    console.error(error);
    process.exitCode = 1;
  });
}

main();
