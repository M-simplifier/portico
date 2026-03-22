import { spawn } from "node:child_process";

function log(message) {
  process.stdout.write(`[pages] ${message}\n`);
}

function npmCommand() {
  return process.platform === "win32" ? "npm.cmd" : "npm";
}

function defaultBaseUrl() {
  const repository = process.env.GITHUB_REPOSITORY ?? "";

  if (repository === "") {
    throw new Error("GITHUB_REPOSITORY is missing. Set PORTICO_BASE_URL manually or run this inside GitHub Actions.");
  }

  const [owner, repoName] = repository.split("/");

  if (!owner || !repoName) {
    throw new Error(`Could not parse GITHUB_REPOSITORY: ${repository}`);
  }

  const ownerSlug = owner.toLowerCase();
  const repoSlug = repoName.toLowerCase();

  if (repoSlug === `${ownerSlug}.github.io`) {
    return `https://${ownerSlug}.github.io/`;
  }

  return `https://${ownerSlug}.github.io/${repoName}/`;
}

function buildBaseUrl() {
  const configuredBaseUrl = process.env.PORTICO_BASE_URL ?? "";
  return configuredBaseUrl === "" ? defaultBaseUrl() : configuredBaseUrl;
}

async function main() {
  const baseUrl = buildBaseUrl();
  log(`building with PORTICO_BASE_URL=${baseUrl}`);

  await new Promise((resolveBuild, rejectBuild) => {
    const child = spawn(npmCommand(), ["run", "build:site"], {
      cwd: process.cwd(),
      env: { ...process.env, PORTICO_BASE_URL: baseUrl },
      stdio: "inherit",
    });

    child.on("exit", (code) => {
      if (code === 0) {
        resolveBuild();
      } else {
        rejectBuild(new Error(`build:site exited with code ${code ?? "unknown"}`));
      }
    });

    child.on("error", rejectBuild);
  });
}

void main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
