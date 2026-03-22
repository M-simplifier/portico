import { spawn } from "node:child_process";

function log(message) {
  process.stdout.write(`[verify] ${message}\n`);
}

function npmCommand() {
  return process.platform === "win32" ? "npm.cmd" : "npm";
}

function runScript(scriptName, extraEnv = {}) {
  return new Promise((resolveRun, rejectRun) => {
    log(`running npm run ${scriptName}`);

    const child = spawn(npmCommand(), ["run", scriptName], {
      cwd: process.cwd(),
      env: { ...process.env, ...extraEnv },
      stdio: "inherit"
    });

    child.on("exit", (code) => {
      if (code === 0) {
        resolveRun();
      } else {
        rejectRun(new Error(`${scriptName} exited with code ${code ?? "unknown"}`));
      }
    });

    child.on("error", rejectRun);
  });
}

async function main() {
  await runScript("check");
  await runScript("build:example");
  await runScript("build:site");

  const pagesBaseUrl = process.env.PORTICO_BASE_URL ?? "https://portico.example.com/";
  log(`running npm run build:pages with PORTICO_BASE_URL=${pagesBaseUrl}`);
  await runScript("build:pages", { PORTICO_BASE_URL: pagesBaseUrl });
}

void main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
