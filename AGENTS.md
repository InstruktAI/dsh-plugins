# AGENTS.md

Working agreements for AI agents (and humans) in this repository.

## What this repo is

[DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) (DSH) plugins maintained by InstruktAI. One directory per plugin; every plugin is a self-contained Cordis package installed into a DSH profile as a bundle.

```
dsh-hooks/   # Claude Code style lifecycle hooks — command/http hooks on agent & tool events
```

Plugin directories are plain directories. Do not turn one into a submodule or a nested git repository — a gitlink makes the plugin's content invisible to every clone.

## How plugins are built and installed

- A plugin is a default-exported Cordis plugin (`{ name, inject, apply(ctx) }`) in `index.mjs` / `index.js`; ESM (`"type": "module"`), Node >= 20.
- `cordis.patch.yml` is the profile bundle patch: installing the package inserts the plugin row into the profile composition. The row's `name` is the package itself.
- `package.json` `dsh.bundle.patch` points at `cordis.patch.yml`. **A plugin without it is never wired**: it lands in the profile's `dependencies` and in no `bundles` list, so it is installed but never loaded. Every plugin here declares it; keep it that way.
- `dsh.client` declares web-platform client requirements; a plugin declares it only when it ships client code (`dsh-hooks` does, in `client/index.js`).
- `dsh plugin add` forwards verbatim to pnpm, so any pnpm source works — including a git ref into this monorepo: `dsh plugin --profile <p> add "github:InstruktAI/dsh-plugins#<ref>&path:/<plugin>"` (quote the `&`). After a successful install the bundle list is reconciled from installed packages, so git-ref installs join the layer stack exactly like npm or tarball installs.
- **`peerDependencies` are a runtime-contract declaration, and every peer must stay `optional` in `peerDependenciesMeta`.** The harness injects these packages through its own loader at runtime; the profile tree neither has nor needs them. A mandatory peer makes the plugin uninstallable or pulls duplicate harness copies into every profile: `@deepseek-ai/dsh-tools@^0.0.1` matches zero published versions (only `rc` prereleases exist, and `^0.0.1` excludes prereleases — pnpm fails with `ERR_PNPM_NO_MATCHING_VERSION`), while resolvable peers (`dsh-shell`, `cordis`, `react`) would be auto-installed as dead weight the plugin's ESM imports can never see from its `file:` install directory. The `optional: true` marker is load-bearing, not a nicety.
- New sessions pick a plugin up automatically; existing sessions must be recreated. Wiring happens on `agent/created`, and a session's tool catalog is pinned at session start — a tool added mid-session is not callable in that session.

## Working here

- **Docs in English.** Plugin READMEs and repo docs are English, and stay in sync with behavior and versions.
- **Keep metadata truthful.** `package.json` `description`, `version`, `repository` and the READMEs must match what the code does. When a description and the implementation diverge, fix the one that is wrong — never document a capability that is not in the file you are describing.
- **Describe what you read, not what you were told.** Before writing that a plugin registers a tool, open the entry point and count the `defineTool` and `ctx.tools.register` calls. A README describing a capability the installed build does not contain is worse than no README.
- **Versioning.** Bump `version` on behavior changes; keep install examples in the READMEs current, tarball filenames included.
- **Tests.** Unit tests live in `<plugin>/test/*.test.mjs` and run with `node --test test/*.test.mjs` (`node:test` + `node:assert/strict`); test files import helpers from the plugin entry point, never from each other. They cover pure helpers, not wiring — the live runtime is the real verification path.
- **Never commit:** `*.tgz`, `*.log`, `.dsh/`, `node_modules/`, editor history, `.DS_Store`, `Thumbs.db`. The root `.gitignore` covers what is common to every plugin; a plugin-local `.gitignore` is for generated output only that plugin produces.

## dsh-hooks specifics

- **CC compatibility boundary is deliberate.** Keep the CC config shape (`matcher[] + hooks[]`, `if`, `timeout`, `once`) and the stdin JSON input / stdout JSON decision protocol, but do not add CC-specific env vars (`CLAUDE_PROJECT_DIR`, `CLAUDE_PLUGIN_ROOT`, …), `${CLAUDE_PLUGIN_ROOT}` substitution, or plugin-hub machinery (`CLAUDE_PLUGIN_OPTION_*`, `CLAUDE_ENV_FILE`). Fields the executor does not honor (`async`, `asyncRewake`, `statusMessage`, non-`bash` `shell`) are rejected at parse time, not silently ignored.
- **Config model.** Four layers, last merged layer wins: global `$DSH_HOME/hooks.json` → preset `<preset-dir>/hooks.json` → project `<project>/.dsh/hooks.json` → project-local `.dsh/hooks.local.json`. Dedup follows CC 2.1.88 `hookDedupKey` (`command` = `shell+command+if`, `http` = `url+if`, `prompt/agent` = `prompt+if`; `callback/function` is never deduped).
- **Events.** Exactly the eleven names in `CC_EVENTS` (`index.mjs`): `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `UserPromptSubmit`, `SessionStart`, `SessionEnd`, `Stop`, `StopFailure`, `SubagentStart`, `SubagentEnd`. Any other key is ignored. Adding an event means wiring it and adding it to that set.
- **Verification.** Install into a profile, run a session, inspect `~/.dsh/logs/dsh-hooks/dsh-hooks.log` or `GET /dsh-hooks/recent`.

## Distribution

Packages here are `private`. Distribution is a git ref into this repository or a local `file:` path — never npm, where the name `dsh-hooks` already belongs to another publisher.
