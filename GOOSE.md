# Using CodeMie frameworks as MCP extensions in goose

CodeMie and [goose](https://github.com/aaif-goose/goose) (AAIF — Agentic AI
Foundation; docs at [goose-docs.ai](https://goose-docs.ai/)) are
two separate agent
runtimes — goose is **not** a CodeMie-managed agent (`codemie install` doesn't
list it). But both speak **MCP (Model Context Protocol)**, so the code-intelligence
servers CodeMie installs as "frameworks" can be consumed by goose too. Build the
index once; query it from `codemie-claude` *and* goose.

> Status: the two routes below are verified in shape, not end-to-end. The exact
> CodeGraph MCP invocation and the proxy's listen URL are marked **TBD** — resolve
> them empirically (see [Unknowns](#unknowns-to-resolve)) before relying on this.

## Why this works

- CodeMie's frameworks are **real MCP servers**, not bespoke plugins:
  - **CodeGraph** → npm `@colbymchenry/codegraph` — local-first code graph / MCP server
  - **Codebase Memory MCP** → persistent code graph + MCP tools + 3D UI (`codemie codebase ui`)
  - **Graphify** → queryable knowledge graph over code/docs/images
- CodeMie manages MCP servers via a proxy: `codemie mcp add <name> <url>` /
  `list` / `remove` (registered through `codemie-mcp-proxy`).
- goose consumes MCP servers as **extensions** — either `type: stdio` (spawn a
  command) or a remote `type: sse` / `streamable_http` (point at a `uri:`).

So the same server can back both agents. There are two ways to wire it.

---

## Route A — point goose at the same server package (simplest)

MCP is a standard, so goose can spawn the exact server CodeMie installs. Install
it once via CodeMie (wires it into Claude / `codemie-claude`):

```bash
codemie install codegraph
```

Then add the **same** server to goose as a stdio extension. Edit
`~/.config/goose/config.yaml` under the top-level `extensions:` map:

```yaml
  codegraph:
    enabled: true
    type: stdio
    name: codegraph
    description: Local-first code intelligence graph (shared with codemie-claude)
    cmd: npx
    args:
    - -y
    - '@colbymchenry/codegraph'   # TBD: real MCP subcommand, e.g. `... mcp` / `... serve`
    envs: {}
    env_keys: []
    timeout: 300
    cwd: null
    bundled: null
```

(The block mirrors the existing `bravesearch` stdio extension already in that
file — copy its shape if in doubt.) Or add it interactively with
`goose configure` → *Add Extension* → *Command-line Extension*.

**Result:** one on-disk index, queried by both agents.
**Trade-off:** each agent spawns its *own* server process over that index.

---

## Route B — share a platform-governed remote MCP server (enterprise)

> ⚠️ **This is not a local-fronting trick.** Inspecting the CLI
> (`dist/cli/commands/proxy/connectors/managed-mcp-remote.js`) shows
> `codemie-mcp-proxy`'s "managed MCP" is a **platform feature**, not a way to
> expose a locally-installed stdio framework. It fetches a *centrally-curated
> catalog* of **remote (URL/SSE) MCP servers** from the CodeMie / AI-Run SSO
> backend and distributes them to your clients:
>
> ```js
> const endpoint = new URL(`${creds.apiUrl}/v1/mcp/managed-servers`);
> endpoint.searchParams.set('client', client);
> if (!creds?.cookies || !creds.apiUrl) {
>   logger.warn('[proxy] Managed MCP fetch skipped: no SSO credentials');
>   return null;   // no SSO login → feature is simply inert
> }
> ```

So Route B is the **enterprise shape**, and it applies to *hosted* MCP servers,
not a local `codemie install codegraph`:

1. An **org admin hosts an MCP server at a URL** and publishes it in the CodeMie
   platform's managed-servers catalog (an admin action against the AI-Run
   platform, e.g. a `codemie.<org>` endpoint).
2. Developers log in with the **`ai-run-sso` provider** (`codemie setup`). CodeMie
   then **auto-distributes** that governed server to their clients — using the
   [`mcp-remote`](https://www.npmjs.com/package/mcp-remote) bridge for stdio-only
   clients.
3. **goose points at the same hosted URL**, so both runtimes share one
   centrally-governed, SSO-authed server. In `~/.config/goose/config.yaml`,
   either natively:

   ```yaml
     shared_graph:
       enabled: true
       type: streamable_http        # or: sse
       name: shared_graph
       description: Org-governed MCP server (shared with codemie-claude)
       uri: https://<org-hosted-mcp-url>
       envs: {}
       timeout: 300
   ```

   or via the same `mcp-remote` stdio bridge CodeMie uses:

   ```yaml
     shared_graph:
       enabled: true
       type: stdio
       name: shared_graph
       cmd: npx
       args: ['-y', 'mcp-remote', 'https://<org-hosted-mcp-url>']
       timeout: 300
   ```

**Result:** one hosted, SSO-governed MCP server, consumed by both agents.
**Prerequisites:** an `ai-run-sso` login **and** a published managed server —
this is an org/admin capability, not a local setup. Without an SSO login the
managed-MCP fetch is skipped entirely (returns `null`), so there is nothing for
goose to share. For a purely local code graph on one machine, use **Route A**.

---

## Pick a graph, don't stack them

CodeGraph, Codebase Memory MCP, and Graphify solve the same problem (a queryable
map of your codebase). Install **one**; running several is redundant and just
burns indexing time and context. CodeGraph is the simplest starting point for
Route A; Codebase Memory adds the `codemie codebase ui` visualizer.

## Unknowns to resolve

1. **CodeGraph's exact MCP command.** `@colbymchenry/codegraph` may need a
   subcommand (`mcp` / `serve`) rather than a bare `npx -y @colbymchenry/codegraph`.
   Verify with the package docs or by running
   `npx -y @colbymchenry/codegraph --help`.
2. **Route B is SSO-gated (resolved).** `codemie-mcp-proxy`'s managed MCP pulls a
   server catalog from `${apiUrl}/v1/mcp/managed-servers` and is inert without an
   `ai-run-sso` login — so Route B can't be validated on an `anthropic-subscription`
   profile. What's still TBD per-org: the hosted server's URL and how goose should
   authenticate to it (bearer header / SSO cookie) when consuming it directly.

## Verifying it works

After wiring either route, start goose and confirm the tools are present:

```bash
goose session        # then ask it to list available tools / use a codegraph tool
```

If the extension failed to load, goose reports it at session start — check the
`cmd`/`args` (Route A) or `uri`/auth (Route B).

## Complementary roles (why bother)

- **goose** — local-first, long autonomous runs, recipes, headless/CI automation.
- **codemie-claude** — governed, audited interactive dev with history + analytics.

Sharing one code-intelligence graph means both agents reason over the **same**
map of your repo, instead of each maintaining its own. See the main
[README](./README.md) for the broader CodeMie + goose infrastructure-sharing
patterns (shared LLM gateway, role split).
