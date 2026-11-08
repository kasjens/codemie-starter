# CodeMie Starter

One-command setup for [CodeMie Code](https://github.com/codemie-ai/codemie-code):
installs the CLI, upgrades the supported agents (Claude Code, Gemini, Codex) to
their minimum versions, runs a health check, and documents the gotchas.

## What is CodeMie, and what does `codemie-claude` do?

CodeMie is a wrapper and control plane around the AI coding agents you already
use (Claude Code, Gemini CLI, Codex). On its own, `claude` talks straight to
Anthropic and leaves no shared trace. CodeMie sits in front of those agents to
add what teams need but the raw CLIs don't:

- One provider config for every agent. Pick your LLM provider and model once in
  `codemie setup`; all agents use it. No per-tool API-key juggling.
- Centralized history and analytics. When you run through CodeMie, your
  conversations and usage can sync to the CodeMie platform, so you (and your org)
  can review what was asked, by whom, and track token and cost usage. The bare
  CLIs don't give you this.
- A consistent entry point. `codemie install`, `codemie doctor`, `codemie setup`,
  and the `codemie-<agent>` wrappers behave the same across every agent and
  framework.

`codemie-claude` is Claude Code launched through CodeMie. You get the same Claude
Code experience, with CodeMie's shared config, history, and analytics on top. It
lets you run Claude (and Gemini, and Codex) under one managed, observable setup
instead of three separate CLIs.

> Why not just `codemie --task`? The bare `codemie` runner is for API-key-style
> providers (litellm/bedrock/ollama and similar). The `anthropic-subscription`
> provider — your native Claude login — runs through the agent wrapper,
> `codemie-claude`. See [Running tasks](#running-tasks).

## Why CodeMie in an enterprise

When AI coding agents go from one developer to a whole organization, the raw
CLIs (`claude`, `gemini`, `codex`) create problems that only show up at scale:

- Visibility and auditability. Individually-run agents leave no shared record, so
  no one can answer "what was the AI asked to do, by whom, against which repo?"
  CodeMie can route conversations and usage to a central platform, giving teams an
  audit trail and reviewable history for compliance and incident review.
- Cost control. Token spend across dozens of developers and three different tools
  is otherwise invisible and hard to attribute. Centralized usage analytics turn
  that into per-user and per-team numbers you can budget and charge back against.
- Config and key sprawl. Without a control plane, every developer wires up their
  own API keys and endpoints for every tool. CodeMie centralizes the provider and
  model choice (including routing through a gateway like LiteLLM, Bedrock, or an
  SSO-backed endpoint), so secrets and model policy live in one place.
- Toolchain drift. Mismatched CLI versions cause subtle behavior differences and
  support pain. `codemie install <agent> --supported` and `codemie doctor` pin
  everyone to a known-good, tested set of versions, which is what this starter
  automates.
- Model and provider governance. A single profile (`codemie setup`) lets an org
  standardize which provider and model are used, rather than each person picking
  their own.
- Onboarding. Getting a new hire productive across Claude, Gemini, and Codex is
  normally a multi-page wiki. `./install.sh` plus `codemie setup` replaces that.
- Fleet-wide extensions. Spec-driven workflows (SpecKit), methodology frameworks
  (BMAD), and shared code-intelligence graphs roll out the same way everywhere via
  `codemie install`, instead of each team improvising its own setup. See
  [Extensions](#extensions-agents-frameworks--add-ons).

The individual CLIs make a developer productive; CodeMie adds the governance, cost
control, and auditability an organization needs around AI-assisted development.

## Quick install

```bash
git clone <this-repo> codemie-starter
cd codemie-starter
./install.sh
```

This installs the CodeMie CLI, brings Claude/Gemini/Codex up to their supported
versions (unattended), and runs `codemie doctor`.

## Setup (configure your profile)

Run the interactive setup once:

```bash
codemie setup
```

It walks you through four choices:

1. Config scope. `Global (~/.codemie/)` works across all repos (recommended), or
   local to the current repo.
2. LLM provider. For example, Anthropic Subscription to reuse your existing Claude
   Code login (no API key stored), or an API-key provider (litellm, bedrock,
   ollama, ai-run-sso, bearer-auth).
3. Platform analytics sync (optional). `Yes` opens a browser to log in to a
   CodeMie platform URL and enables history and usage sync; `No` skips it, and you
   can still use every agent. Pressing `Ctrl+C` at the browser step aborts the
   whole setup, so choose `No` if you want to skip sync.
4. Model and profile name. For example, model `opus`, profile `default`.

Verify afterwards:

```bash
codemie doctor
```

A healthy profile shows `Provider: anthropic-subscription`, a base URL, and your
model. Config is written to `~/.codemie/codemie-cli.config.json`.

## Running tasks

Which command runs a task depends on the provider you picked in `codemie setup`:

| Provider | Run tasks with |
| --- | --- |
| `anthropic-subscription` (native Claude login) | `codemie-claude --task "..."` or `codemie-claude` |
| `litellm` / `bedrock` / `ollama` / `ai-run-sso` / `bearer-auth` | `codemie --task "..."` |

```bash
codemie-claude --task "summarize this repo"   # single task
codemie-claude                                # interactive session
```

> The bare `codemie --task` runner does not support `anthropic-subscription`. If
> you set up that provider and run `codemie --task`, you'll see
> "Supported providers: litellm, ai-run-sso, ollama, bedrock, bearer-auth" — use
> `codemie-claude` instead.

## Extensions (agents, frameworks & add-ons)

Everything beyond the core agents is optional and installed the same way:

```bash
codemie install            # list everything available + install status
codemie install <name>     # install one
codemie uninstall <name>   # remove one
```

In `codemie doctor`, a `○` next to a framework means not installed. It is
informational, not an error. Install only what you'll use.

### Additional agents

| Name | Install | What it is |
| --- | --- | --- |
| OpenCode CLI | `codemie install opencode` | Open-source AI coding assistant |
| Claude / Gemini / Codex ACP | `codemie install <agent>-acp` | Editor-integration (Zed, JetBrains, Emacs) adapters |

### Workflow methodologies

| Name | Install | What it is |
| --- | --- | --- |
| SpecKit | `codemie install speckit` | GitHub's spec-driven development toolkit: write a spec, generate from it |
| BMAD Method | `codemie install bmad` | Heavier "agile with AI agents" methodology; useful only if you adopt the process |

### Code-intelligence graphs (pick at most one; they overlap)

| Name | Install | What it is |
| --- | --- | --- |
| Codebase Memory MCP | `codemie install codebase-memory` | Persistent code graph + MCP tools + 3D UI (`codemie codebase ui`) |
| CodeGraph | `codemie install codegraph` | Local-first code graph / MCP server for agents |
| Graphify | `codemie install graphify` | Queryable knowledge graph over code/docs/images (Claude Code skill) |

These give an agent a queryable map of your codebase, useful on large repos and
overkill on small ones. Don't run more than one; they do the same job.

> These are standard MCP servers, so you can share one with
> [goose](https://github.com/aaif-goose/goose) (AAIF) and have both
> `codemie-claude` and goose query the same code graph. See [GOOSE.md](./GOOSE.md).

### Add-ons

| Name | Install | What it is |
| --- | --- | --- |
| CodeMie Statusline | `codemie install statusline` | Project, branch, model, context usage, session cost & duration in Claude Code |

For a fresh setup, skip the methodologies and graph tools until you have a
concrete need. The statusline is a low-effort add-on worth enabling.

## `install.sh` options

| Command | What it does |
| --- | --- |
| `./install.sh` | Install the CLI, upgrade supported agents, run health check |
| `./install.sh --check` | Health check only; changes nothing |
| `./install.sh --no-agents` | Install the CLI only, skip agent upgrades |
| `make install` | Same as `./install.sh` |
| `make check` | Same as `./install.sh --check` |
| `make task T="..."` | Run a one-off task via `codemie-claude` |

## Requirements

- Node.js >= 20 (`node --version`)
- npm
- `curl` (for the first-time CLI bootstrap)
- AWS CLI (optional; only needed for Bedrock profile management)

## What the health check looks for

`codemie doctor` reports on Node/npm/Python/uv versions, your active profile,
installed agent versions, and optional frameworks. Common first-run findings:

| Finding | What to do |
| --- | --- |
| No configuration found | Run `codemie setup` |
| Agent below minimum supported version | `codemie install <agent> --supported` |
| AWS CLI not found | Optional; install only if you use Bedrock |
| VCS provider not detected | The repo has no recognized remote; harmless |
| Frameworks `○` not installed | Optional; see [Extensions](#extensions-agents-frameworks--add-ons) |

## Notes

- Unattended by default. When an agent upgrade is pending, `codemie install` asks
  `Reinstall? (y/N)`; the script feeds it `y` so no manual input is needed. Agents
  already at the supported version skip the prompt.
- codemie-code is not auto-upgraded. `codemie install codemie-code --supported`
  fails with "No supported version defined in metadata", and installing it tries
  to create `~/.local/bin/codemie`, which collides with the CodeMie CLI binary.
  The CLI itself is kept current by the `npm install -g @codemieai/code@latest`
  step, so the health-check "recommends vlatest" note for CodeMie Code can be
  ignored.
- The upstream installer lives at
  `codemie-ai/codemie-code/main/install/macos/install.sh`. It also works on Linux
  despite the `macos` path. Override with `CODEMIE_INSTALL_URL` if that path
  changes.
- The CLI installs as a global npm package (`@codemieai/code`).
