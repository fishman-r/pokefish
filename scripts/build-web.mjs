import { cp, mkdir, rm } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = dirname(dirname(fileURLToPath(import.meta.url)));
const dist = join(root, "dist");

await rm(dist, { recursive: true, force: true });
await mkdir(dist, { recursive: true });

await Promise.all([
  cp(join(root, "index.html"), join(dist, "index.html")),
  cp(join(root, "styles.css"), join(dist, "styles.css")),
  cp(join(root, "src"), join(dist, "src"), { recursive: true }),
]);

console.log("Built static app into dist/");
