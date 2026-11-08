# CodeMie Starter

A one-command setup for [CodeMie Code](https://github.com/codemie-ai/codemie-code):
installs the CLI, upgrades every supported agent (Claude Code, Gemini, Codex)
to its minimum version, runs a health check, and documents the gotchas so you
don't rediscover them.

## What is CodeMie — and what does `codemie-claude` solve?

CodeMie is a **wrapper and control plane around the AI coding agents you already
use** (Claude Code, Gemini CLI, Codex). On its own, `claude` talks straight to
Anthropic and leaves no shared trace. CodeMie sits in front of those agents to
add the things teams need but the raw CLIs don't:

- **One provider config for every agent.** Pick your LLM provider / model once in
  `codemie setup`; all agents use it. No per-tool API-key juggling.
- **Centralized history & analytics.** When you run through CodeMie, your
  conversations and usage can sync to the CodeMie platform so you (and your org)
  can review what was asked, track token/cost usage, and spot patterns —
  visibility the bare CLIs don't give you.
- **A consistent entry point.** `codemie install`, `codemie doctor`,
  `codemie setup`, and the `codemie-<agent>` wrappers behave the same across
  every agent and framework.

So **`codemie-claude` is Claude Code, launched *through* CodeMie.** You get the
exact Claude Code experience, but with CodeMie's shared config, history, and
analytics layered on. The problem it solves: using Claude (and Gemini, and
Codex) under **one managed, observable setup** instead of three disconnected,
invisible CLIs.

> Why not just `codemie --task`? The bare `codemie` runner is for API-key-style
> providers (litellm/bedrock/ollama/…). The `anthropic-subscription` provider —
> your native Claude login — runs through the agent wrapper, i.e.
> `codemie-claude`. See [Running tasks](#running-tasks).

## Why CodeMie in an enterprise

When AI coding agents go from one developer to a whole organization, the raw
CLIs (`claude`, `gemini`, `codex`) create problems that only show up at scale.
CodeMie exists to solve those:

- **No visibility / auditability.** Individually-run agents leave no shared
  record — no one can answer "what was the AI asked to do, by whom, against which
  repo?" CodeMie can route conversations and usage to a central platform, giving
  teams an audit trail and reviewable history for compliance and incident review.
- **Uncontrolled cost.** Token spend across dozens of developers and three
  different tools is invisible and un-attributable. Centralized usage analytics
  turn that into per-user / per-team numbers you can actually budget and
  chargeback against.
- **Config & key sprawl.** Without a control plane, every developer wires up
  their own API keys and endpoints for every tool. CodeMie centralizes the
  provider/model choice (including routing through an enterprise gateway like
  LiteLLM, Bedrock, or an SSO-backed endpoint) so secrets and model policy live
  in one place, not scattered across laptops.
- **Inconsistent, drifting toolchains.** "Works on my machine" applies to agents
  too — mismatched CLI versions cause subtle behavior differences and support
  pain. `codemie install <agent> --supported` and `codemie doctor` pin everyone
  to a **known-good, tested set of versions**, which is exactly what this starter
  automates.
- **Model & provider governance.** Enterprises need to say "use *this* model,
  through *this* approved provider." A single profile (`codemie setup`) lets an
  org standardize which provider and model are used, rather than each person
  picking their own.
- **Fragmented onboarding.** Getting a new hire productive across Claude, Gemini,
  and Codex is normally a multi-page wiki. One `./install.sh` + `codemie setup`
  replaces that, which is the whole point of this repo.
- **Fleet-wide extensions.** Spec-driven workflows (SpecKit), methodology
  frameworks (BMAD), and shared code-intelligence graphs can be rolled out the
  same way everywhere via `codemie install`, instead of each team improvising its
  own setup. See [Extensions](#extensions-agents-frameworks--add-ons).

In short: the individual CLIs make a **developer** productive; CodeMie makes an
**organization** productive — with the governance, cost control, and auditability
an enterprise needs around AI-assisted development.

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

1. **Config scope** — `Global (~/.codemie/)` works across all repos (recommended)
   or local to the current repo.
2. **LLM provider** — e.g. **Anthropic Subscription** to reuse your existing
   Claude Code login (no API key stored), or an API-key provider (litellm,
   bedrock, ollama, ai-run-sso, bearer-auth).
3. **Platform analytics sync** — optional. `Yes` opens a browser to log in to a
   CodeMie platform URL and enables history/usage sync; `No` skips it entirely
   (you can still use every agent). Pressing `Ctrl+C` at the browser step aborts
   the *whole* setup — choose `No` if you want to skip sync.
4. **Model + profile name** — e.g. model `opus`, profile `default`.

Verify afterwards:

```bash
codemie doctor
```

A healthy profile shows: `Provider: anthropic-subscription`, a base URL, and your
model. Config is written to `~/.codemie/codemie-cli.config.json`.

## Running tasks

Which command runs a task depends on the **provider** you picked in `codemie setup`:

| Provider | Run tasks with |
| --- | --- |
| `anthropic-subscription` (native Claude login) | `codemie-claude --task "..."` or `codemie-claude` |
| `litellm` / `bedrock` / `ollama` / `ai-run-sso` / `bearer-auth` | `codemie --task "..."` |

```bash
codemie-claude --task "summarize this repo"   # single task
codemie-claude                                # interactive session
```

> ⚠️ The bare `codemie --task` runner does **not** support
> `anthropic-subscription`. If you set up that provider and run `codemie --task`,
> you'll see *"Supported providers: litellm, ai-run-sso, ollama, bedrock,
> bearer-auth"* — use `codemie-claude` instead.

## Extensions (agents, frameworks & add-ons)

Everything beyond the core agents is **optional** and installed the same way:

```bash
codemie install            # list everything available + install status
codemie install <name>     # install one
codemie uninstall <name>   # remove one
```

In `codemie doctor`, a `○` next to a framework means *not installed* — it is
**informational, not an error**. Install only what you'll actually use.

### Additional agents

| Name | Install | What it is |
| --- | --- | --- |
| OpenCode CLI | `codemie install opencode` | Open-source AI coding assistant |
| Claude / Gemini / Codex ACP | `codemie install <agent>-acp` | Editor-integration (Zed, JetBrains, Emacs) adapters |

### Workflow methodologies

| Name | Install | What it is |
| --- | --- | --- |
| SpecKit | `codemie install speckit` | GitHub's spec-driven development toolkit — write a spec, generate from it |
| BMAD Method | `codemie install bmad` | Heavier "agile with AI agents" methodology; worth it only if you adopt the process |

### Code-intelligence graphs — pick **at most one** (they overlap)

| Name | Install | What it is |
| --- | --- | --- |
| Codebase Memory MCP | `codemie install codebase-memory` | Persistent code graph + MCP tools + 3D UI (`codemie codebase ui`) |
| CodeGraph | `codemie install codegraph` | Local-first code graph / MCP server for agents |
| Graphify | `codemie install graphify` | Queryable knowledge graph over code/docs/images (Claude Code skill) |

These give an agent a queryable map of your codebase — useful on large repos,
overkill on small ones. Don't run more than one; they do the same job.

> 💡 Because these are standard **MCP servers**, you can share one with
> [goose](https://goose-docs.ai/) (AAIF) so both `codemie-claude` and goose
> query the same code graph. See [GOOSE.md](./GOOSE.md).

### Add-ons

| Name | Install | What it is |
| --- | --- | --- |
| CodeMie Statusline | `codemie install statusline` | Project, branch, model, context usage, session cost & duration in Claude Code |

**Recommendation for a fresh setup:** skip the methodologies and graph tools
until you have a concrete need. The **statusline** is the one cheap, genuinely
useful add-on.

## `install.sh` options

| Command | What it does |
| --- | --- |
| `./install.sh` | Install the CLI + upgrade supported agents + health check |
| `./install.sh --check` | Health check only — changes nothing |
| `./install.sh --no-agents` | Install the CLI only, skip agent upgrades |
| `make install` | Same as `./install.sh` |
| `make check` | Same as `./install.sh --check` |
| `make task T="..."` | Run a one-off task via `codemie-claude` |

## Requirements

- **Node.js ≥ 20** (`node --version`)
- **npm**
- `curl` (for the first-time CLI bootstrap)
- Optional: **AWS CLI** — only needed for Bedrock profile management

## What the health check looks for

`codemie doctor` reports on Node/npm/Python/uv versions, your active profile,
installed agent versions, and optional frameworks. Common first-run findings:

- **No configuration found** → run `codemie setup`
- **Agent below minimum supported version** → `codemie install <agent> --supported`
- **AWS CLI not found** → optional, install only if you use Bedrock
- **VCS provider not detected** → the repo has no recognized remote; harmless
- **Frameworks `○` not installed** → optional, see [Extensions](#extensions-agents-frameworks--add-ons)

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
