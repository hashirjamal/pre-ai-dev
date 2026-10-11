#!/usr/bin/env node
// SessionStart hook: adds a short reminder about the 3 skills and the review gate to the context.
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const pluginRoot = process.env.CLAUDE_PLUGIN_ROOT ?? join(dirname(fileURLToPath(import.meta.url)), "..");

function readVersion() {
  try {
    const manifest = JSON.parse(readFileSync(join(pluginRoot, ".claude-plugin", "plugin.json"), "utf8"));
    return manifest.version ?? "unknown";
  } catch {
    return "unknown";
  }
}

// Facts, not commands: text that reads like a system instruction can be treated as a prompt injection.
const context = [
  `The pre-ai-dev plugin (version ${readVersion()}) is active in this session.`,
  "It provides 3 skills: pre-ai-dev:build for new features, pre-ai-dev:refactor for restructuring with no behavior change, pre-ai-dev:debug for broken behavior.",
  "The user of this plugin reviews code before each commit: a commit, push or merge follows only after the user approves a Files-to-review list.",
  "The user expects short, plain reports in the chat, and no new Markdown files in a project unless the user asks for them.",
].join("\n");

process.stdout.write(
  JSON.stringify({ hookSpecificOutput: { hookEventName: "SessionStart", additionalContext: context } }),
);
