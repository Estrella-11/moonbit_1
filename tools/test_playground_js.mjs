// Verifies the browser bundle produced by `moon build --target js cmd/playground`.
//
// The playground compiles MoonBit to JavaScript and calls it from the page. That
// boundary is the one part a type check cannot prove, so this script loads the
// generated bundle in Node, calls the exposed functions, and asserts on real
// output — including that user Markdown cannot inject HTML.
//
// Usage: node tools/test_playground_js.mjs <path-to-bundle.js>

import { pathToFileURL } from "node:url";
import { readFileSync } from "node:fs";

const target = process.argv[2];

if (!target) {
  console.error("usage: node tools/test_playground_js.mjs <bundle.js>");
  process.exit(1);
}

const failures = [];

function check(name, condition, detail) {
  if (condition) {
    console.log(`  ok   ${name}`);
  } else {
    failures.push(name);
    console.log(`  FAIL ${name}${detail ? ` — ${detail}` : ""}`);
  }
}

function parseStats(text) {
  const out = {};
  for (const line of String(text).split("\n")) {
    const index = line.indexOf("=");
    if (index > 0) out[line.slice(0, index)] = line.slice(index + 1);
  }
  return out;
}

console.log(`Playground bundle: ${target}`);

const source = readFileSync(target, "utf-8");
check("bundle is not empty", source.length > 0, `${source.length} bytes`);

await import(pathToFileURL(target).href);

const render = globalThis.moonDocKitRenderPage;
const stats = globalThis.moonDocKitPageStats;

check("render entry point is exposed", typeof render === "function", typeof render);
check("stats entry point is exposed", typeof stats === "function", typeof stats);

if (typeof render !== "function" || typeof stats !== "function") {
  console.error("\nPlayground bridge was not published to globalThis.");
  process.exit(1);
}

const markdown = [
  "---",
  "title: Playground",
  "order: 0",
  "---",
  "# Playground",
  "",
  "Hello from the playground.",
  "",
  "```moonbit",
  "fn greet() -> String { \"hi\" }",
  "```",
].join("\n");

const html = render(markdown, "Playground", "default");

check("render returns a string", typeof html === "string", typeof html);
check("render emits a full document", html.includes("<!doctype html>"), html.slice(0, 40));
check("render includes the page title", html.includes("Playground"));
check("render includes body content", html.includes("Hello from the playground."));
check("render labels fenced code blocks", html.includes("moonbit"));

const themed = render(markdown, "Playground", "package");
check("theme selection changes output", themed !== html);

const hostile = "# Hi\n\n<script>alert(1)</script>\n";
const escaped = render(hostile, "Hostile", "default");
check(
  "user HTML is escaped, not executed",
  !escaped.includes("<script>alert(1)</script>") && escaped.includes("&lt;script&gt;"),
);

const parsed = parseStats(stats(markdown, "Playground"));
check("stats reports a score", parsed.score !== undefined, JSON.stringify(parsed));
check("stats reports the publish gate", parsed.passed === "1", JSON.stringify(parsed));
check("stats counts headings", Number(parsed.headings) > 0, parsed.headings);
check("stats counts code blocks", Number(parsed.code_blocks) > 0, parsed.code_blocks);
check("stats counts words", Number(parsed.words) > 0, parsed.words);
check("stats lists quality checks", Object.keys(parsed).some((key) => key.startsWith("check_")));

const emptyStats = parseStats(stats("", "Empty"));
check("empty input does not throw", emptyStats.score !== undefined, JSON.stringify(emptyStats));

if (failures.length > 0) {
  console.error(`\n${failures.length} playground check(s) failed.`);
  process.exit(1);
}

console.log("\nPlayground bundle verified.");
