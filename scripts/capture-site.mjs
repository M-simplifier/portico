import { spawn, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = resolve(fileURLToPath(new URL(".", import.meta.url)));
const projectRoot = resolve(scriptDirectory, "..");
const outputDirectory = resolve(projectRoot, "site/review");
const port = Number.parseInt(process.env.PORT ?? "4175", 10);
const serverUrl = `http://127.0.0.1:${port}`;
const chromePath = process.env.CHROME_BIN ?? detectChrome();

const screenshotTargets = [
  { name: "official-home-desktop", path: "/", width: 1440, height: 4200, waitMs: 1200 },
  { name: "official-home-mobile", path: "/", width: 430, height: 5200, waitMs: 1200 },
  { name: "official-home-ja-desktop", path: "/ja/", width: 1440, height: 4200, waitMs: 2600 },
  { name: "sample-lab-desktop", path: "/lab/", width: 1440, height: 4600, waitMs: 1200 },
  { name: "preset-catalog-desktop", path: "/lab/presets.html", width: 1440, height: 4600, waitMs: 1200 },
  { name: "northstar-desktop", path: "/samples/northstar-cloud/index.html", width: 1440, height: 4600, waitMs: 1200 },
  { name: "mina-case-study-desktop", path: "/samples/mina-arai/work/harbor-clinic.html", width: 1440, height: 4800, waitMs: 1200 },
];

function log(message) {
  process.stdout.write(`[screenshot] ${message}\n`);
}

function detectChrome() {
  const candidates = [
    "google-chrome",
    "google-chrome-stable",
    "chromium-browser",
    "chromium",
  ];

  for (const candidate of candidates) {
    const result = spawnSync("which", [candidate], { encoding: "utf8" });
    if (result.status === 0) {
      return result.stdout.trim();
    }
  }

  throw new Error("Could not find a Chrome/Chromium binary. Set CHROME_BIN to continue.");
}

function ensureOutputDirectory() {
  mkdirSync(outputDirectory, { recursive: true });
}

function startServer() {
  return new Promise((resolveServer, rejectServer) => {
    const child = spawn(process.execPath, [resolve(projectRoot, "scripts/dev-site.mjs"), "--no-watch"], {
      cwd: projectRoot,
      env: { ...process.env, PORT: String(port) },
      stdio: ["ignore", "pipe", "pipe"],
    });

    const onData = (chunk) => {
      const text = chunk.toString();
      process.stdout.write(text);

      if (text.includes(`official site: ${serverUrl}/`)) {
        resolveServer(child);
      }
    };

    child.stdout.on("data", onData);
    child.stderr.on("data", (chunk) => {
      process.stderr.write(chunk);
    });

    child.on("error", rejectServer);
    child.on("exit", (code) => {
      if (code !== null && code !== 0) {
        rejectServer(new Error(`serve:site exited early with code ${code}`));
      }
    });
  });
}

function stopServer(child) {
  return new Promise((resolveStop) => {
    let settled = false;

    const finish = () => {
      if (!settled) {
        settled = true;
        resolveStop();
      }
    };

    child.once("exit", finish);
    child.kill("SIGTERM");

    setTimeout(() => {
      if (child.exitCode === null) {
        child.kill("SIGKILL");
      }
      finish();
    }, 1000);
  });
}

function captureScreenshot(target) {
  return new Promise((resolveCapture, rejectCapture) => {
    const destination = resolve(outputDirectory, `${target.name}.png`);
    const child = spawn(
      chromePath,
      [
        "--headless=new",
        "--disable-gpu",
        "--hide-scrollbars",
        "--no-sandbox",
        "--run-all-compositor-stages-before-draw",
        `--virtual-time-budget=${target.waitMs ?? 0}`,
        `--window-size=${target.width},${target.height}`,
        `--screenshot=${destination}`,
        `${serverUrl}${target.path}`,
      ],
      { stdio: "ignore" }
    );

    child.on("exit", (code) => {
      if (code === 0 && existsSync(destination)) {
        resolveCapture({
          name: target.name,
          path: target.path,
          file: destination,
          width: target.width,
          height: target.height,
          waitMs: target.waitMs ?? 0,
        });
      } else {
        rejectCapture(new Error(`Screenshot failed for ${target.path} with code ${code ?? "unknown"}`));
      }
    });

    child.on("error", rejectCapture);
  });
}

async function main() {
  ensureOutputDirectory();
  log(`using chrome binary: ${chromePath}`);
  const server = await startServer();

  try {
    const manifest = [];

    for (const target of screenshotTargets) {
      log(`capturing ${target.path}`);
      manifest.push(await captureScreenshot(target));
    }

    const manifestPath = resolve(outputDirectory, "manifest.json");
    writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
    log(`wrote ${manifest.length} screenshots to ${outputDirectory}`);
    log(`manifest: ${manifestPath}`);
  } finally {
    await stopServer(server);
  }
}

void main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
