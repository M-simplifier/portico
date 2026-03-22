import { spawn } from "node:child_process";
import { createServer } from "node:http";
import { existsSync, readFileSync, readdirSync, statSync, watch } from "node:fs";
import { extname, join, normalize, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = resolve(fileURLToPath(new URL(".", import.meta.url)));
const projectRoot = resolve(scriptDirectory, "..");
const outputDirectory = resolve(projectRoot, "site/dist");
const port = Number.parseInt(process.env.PORT ?? "4174", 10);
const watchEnabled = !process.argv.includes("--no-watch");

const watchTargets = [
  "src",
  "docs",
  "examples/official",
  "README.md",
  "ROADMAP.md",
  "package.json",
  "spago.yaml",
  "spago.lock",
];

const contentTypes = {
  ".css": "text/css; charset=utf-8",
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".txt": "text/plain; charset=utf-8",
  ".xml": "application/xml; charset=utf-8",
};

let buildInFlight = false;
let pendingBuild = false;
let rebuildTimer = null;
let watchers = [];
let serverStarted = false;

function log(message) {
  process.stdout.write(`[dev] ${message}\n`);
}

function npmCommand() {
  return process.platform === "win32" ? "npm.cmd" : "npm";
}

function runBuild() {
  return new Promise((resolveBuild, rejectBuild) => {
    const child = spawn(npmCommand(), ["run", "build:site"], {
      cwd: projectRoot,
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

async function ensureBuild() {
  if (buildInFlight) {
    pendingBuild = true;
    return;
  }

  buildInFlight = true;

  do {
    pendingBuild = false;
    try {
      log("building official site");
      await runBuild();
      log("build complete");
    } catch (error) {
      log(`build failed: ${error.message}`);
    }
  } while (pendingBuild);

  buildInFlight = false;
}

function buildOnceSoon() {
  if (rebuildTimer !== null) {
    clearTimeout(rebuildTimer);
  }

  rebuildTimer = setTimeout(() => {
    rebuildTimer = null;
    void ensureBuild();
  }, 120);
}

function collectDirectories(targetPath) {
  if (!existsSync(targetPath)) {
    return [];
  }

  const directories = [];
  const currentStat = statSync(targetPath);

  if (!currentStat.isDirectory()) {
    return directories;
  }

  directories.push(targetPath);

  for (const entry of readdirSync(targetPath, { withFileTypes: true })) {
    if (entry.isDirectory()) {
      directories.push(...collectDirectories(join(targetPath, entry.name)));
    }
  }

  return directories;
}

function refreshWatchers() {
  for (const currentWatcher of watchers) {
    currentWatcher.close();
  }

  watchers = [];

  for (const target of watchTargets) {
    const absoluteTarget = resolve(projectRoot, target);

    if (!existsSync(absoluteTarget)) {
      continue;
    }

    const currentStat = statSync(absoluteTarget);

    if (currentStat.isDirectory()) {
      for (const directory of collectDirectories(absoluteTarget)) {
        watchers.push(
          watch(directory, () => {
            refreshWatchers();
            buildOnceSoon();
          })
        );
      }
    } else {
      watchers.push(
        watch(absoluteTarget, () => {
          buildOnceSoon();
        })
      );
    }
  }
}

function safeOutputPath(urlPath) {
  const trimmedPath = decodeURIComponent(urlPath.split("?")[0]);
  const requestedPath = trimmedPath === "/" ? "/index.html" : trimmedPath;
  const normalizedPath = normalize(requestedPath).replace(/^(\.\.[/\\])+/, "");
  let filesystemPath = resolve(outputDirectory, `.${normalizedPath}`);

  if (existsSync(filesystemPath) && statSync(filesystemPath).isDirectory()) {
    filesystemPath = join(filesystemPath, "index.html");
  } else if (!extname(filesystemPath) && existsSync(`${filesystemPath}.html`)) {
    filesystemPath = `${filesystemPath}.html`;
  }

  if (!filesystemPath.startsWith(outputDirectory)) {
    return null;
  }

  return filesystemPath;
}

function startServer() {
  if (serverStarted) {
    return;
  }

  const server = createServer((request, response) => {
    const requestPath = request.url ?? "/";
    const filesystemPath = safeOutputPath(requestPath);

    if (filesystemPath === null || !existsSync(filesystemPath) || statSync(filesystemPath).isDirectory()) {
      response.writeHead(404, { "content-type": "text/plain; charset=utf-8" });
      response.end("Not found");
      return;
    }

    const extension = extname(filesystemPath);
    response.writeHead(200, {
      "content-type": contentTypes[extension] ?? "application/octet-stream",
      "cache-control": "no-cache",
    });
    response.end(readFileSync(filesystemPath));
  });

  server.listen(port, "127.0.0.1", () => {
    serverStarted = true;
    log(`serving ${outputDirectory}`);
    log(`official site: http://127.0.0.1:${port}/`);
    log(`sample lab: http://127.0.0.1:${port}/lab/`);
  });
}

async function main() {
  await ensureBuild();
  startServer();

  if (watchEnabled) {
    refreshWatchers();
    log("watching source files for rebuilds");
  } else {
    log("watch mode disabled");
  }
}

void main();
