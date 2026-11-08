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

- Upstream installer lives at
  `codemie-ai/codemie-code/main/install/macos/install.sh` — it also works on
  Linux despite the `macos` path. Override with `CODEMIE_INSTALL_URL` if that
  path changes.
- The CLI installs as a global npm package (`@codemieai/code`).
