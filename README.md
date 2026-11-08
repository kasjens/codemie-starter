# CodeMie Starter

A one-command setup for [CodeMie Code](https://github.com/codemie-ai/codemie-code):
installs the CLI, upgrades every supported agent (Claude Code, Gemini, Codex,
CodeMie Code) to its minimum version, and runs a health check.

## Quick install

```bash
git clone <this-repo> codemie-starter
cd codemie-starter
./install.sh
```

Then configure your profile:

```bash
codemie setup
```

## Running tasks

Which command runs a task depends on the **provider** you picked in `codemie setup`:

| Provider | Run tasks with |
| --- | --- |
| `anthropic-subscription` (native Claude login) | `codemie-claude --task "..."` or `codemie-claude` |
| `litellm` / `bedrock` / `ollama` / `ai-run-sso` / `bearer-auth` | `codemie --task "..."` |

> ⚠️ The bare `codemie --task` runner does **not** support
> `anthropic-subscription`. If you set up that provider and run `codemie --task`,
> you'll see *"Supported providers: litellm, ai-run-sso, ollama, bedrock,
> bearer-auth"* — use `codemie-claude` instead.

## Options

| Command | What it does |
| --- | --- |
| `./install.sh` | Install the CLI + upgrade supported agents + health check |
| `./install.sh --check` | Health check only — changes nothing |
| `./install.sh --no-agents` | Install the CLI only, skip agent upgrades |
| `make install` | Same as `./install.sh` |
| `make check` | Same as `./install.sh --check` |

## Requirements

- **Node.js ≥ 20** (`node --version`)
- **npm**
- `curl` (for the first-time CLI bootstrap)
- Optional: **AWS CLI** — only needed for Bedrock profile management

## What the health check looks for

`codemie doctor` reports on Node/npm/Python/uv versions, your active profile,
and installed agent versions. Common first-run findings:

- **No configuration found** → run `codemie setup`
- **Agent below minimum supported version** → `codemie install <agent> --supported`
- **AWS CLI not found** → optional, install only if you use Bedrock

## Notes

- **Unattended by default.** When an agent upgrade is pending, `codemie install`
  asks `Reinstall? (y/N)`; the script feeds it `y` so no manual input is needed.
  Agents already at the supported version skip the prompt entirely.
- **codemie-code is deliberately not auto-upgraded.** `codemie install
  codemie-code --supported` fails with *"No supported version defined in
  metadata"*, and installing it tries to create `~/.local/bin/codemie`, which
  collides with the CodeMie CLI binary. The CLI itself is kept current by the
  `npm install -g @codemieai/code@latest` step, so the health-check
  "recommends vlatest" note for CodeMie Code can be safely ignored.
- Upstream installer lives at
  `codemie-ai/codemie-code/main/install/macos/install.sh` — it also works on
  Linux despite the `macos` path. Override with `CODEMIE_INSTALL_URL` if that
  path changes.
- The CLI installs as a global npm package (`@codemieai/code`).
