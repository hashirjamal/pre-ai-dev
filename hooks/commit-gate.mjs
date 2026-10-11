#!/usr/bin/env node
// PreToolUse hook for Bash: asks the user to confirm each `git commit`, `git push` and `git merge`.
// It never blocks a command by itself. It turns the tool call into a permission prompt.

const GATED_SUBCOMMANDS = new Set(["commit", "push", "merge"]);
// Global git options that take a separate value, for example `git -C path commit`.
const OPTIONS_WITH_VALUE = new Set(["-C", "-c", "--git-dir", "--work-tree", "--namespace", "--exec-path"]);
const COMMAND_SEPARATORS = /&&|\|\||[;|\n]|\$\(|`/;
const ENV_ASSIGNMENT = /^[A-Za-z_][A-Za-z0-9_]*=/;
const COMMAND_PREFIXES = new Set(["sudo", "command", "exec", "time", "env"]);

function isGateEnabled() {
  const option = (process.env.CLAUDE_PLUGIN_OPTION_COMMIT_GATE ?? "true").toLowerCase();
  return option !== "false" && option !== "0";
}

/** Returns the gated git subcommand of one shell segment, or null. */
function findGatedSubcommand(segment) {
  const tokens = segment.trim().split(/\s+/).filter(Boolean);
  let index = 0;
  while (index < tokens.length && (ENV_ASSIGNMENT.test(tokens[index]) || COMMAND_PREFIXES.has(tokens[index]))) {
    index++;
  }
  const program = tokens[index]?.replace(/^["'(]+/, "");
  if (program !== "git" && !program?.endsWith("/git")) return null;
  index++;
  while (index < tokens.length && tokens[index].startsWith("-")) {
    index += OPTIONS_WITH_VALUE.has(tokens[index]) ? 2 : 1;
  }
  const subcommand = tokens[index];
  return GATED_SUBCOMMANDS.has(subcommand) ? subcommand : null;
}

function readStdin() {
  return new Promise((resolve) => {
    let data = "";
    process.stdin.setEncoding("utf8");
    process.stdin.on("data", (chunk) => (data += chunk));
    process.stdin.on("end", () => resolve(data));
  });
}

async function main() {
  if (!isGateEnabled()) return;
  let input;
  try {
    input = JSON.parse(await readStdin());
  } catch {
    return; // No decision. The normal permission flow applies.
  }
  const command = input?.tool_input?.command;
  if (input?.tool_name !== "Bash" || typeof command !== "string") return;

  const subcommands = command.split(COMMAND_SEPARATORS).map(findGatedSubcommand).filter(Boolean);
  if (subcommands.length === 0) return;

  const names = [...new Set(subcommands)].map((name) => `git ${name}`).join(", ");
  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "ask",
        permissionDecisionReason: `pre-ai-dev review gate: ${names}. Approve only after you read the files in the Files-to-review list.`,
      },
    }),
  );
}

await main();
