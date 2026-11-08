# Using CodeMie frameworks as MCP extensions in goose

CodeMie and [goose](https://github.com/block/goose) are two separate agent
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

## Route B — share one instance via `codemie-mcp-proxy` (governed)

Instead of each agent spawning its own server, let CodeMie front the MCP
server(s) behind its proxy, and have goose point at that URL as a **remote**
extension. Both agents then hit one running server through one managed, authable
proxy — the right shape when you also run the `ai-run-sso` provider for
centralized, SSO-governed access.

```bash
codemie install codegraph                 # or codebase-memory / graphify
codemie mcp add codegraph <server-url>     # register upstream via codemie-mcp-proxy
codemie mcp list                           # confirm registration
```

Then in goose, add a remote extension pointing at the proxy's endpoint
(`goose configure` → *Add Extension* → *Remote Extension*), or in
`~/.config/goose/config.yaml`:

```yaml
  codegraph_remote:
    enabled: true
    type: streamable_http          # or: sse
    name: codegraph_remote
    description: Shared code graph via codemie-mcp-proxy
    uri: <proxy-url>               # TBD: codemie-mcp-proxy listen URL
    envs: {}
    timeout: 300
```

**Result:** a single server instance behind one governed proxy, shared by both
agents.
**Gate:** requires confirming the proxy's own listen URL + auth (below).

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
2. **`codemie-mcp-proxy` listen URL + auth (Route B).** `codemie mcp add` takes a
   URL as an *upstream input*; confirm the proxy exposes a single aggregate
   endpoint goose can reach, and how it authenticates, before relying on Route B.

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
