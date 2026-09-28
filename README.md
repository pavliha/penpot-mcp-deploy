# penpot-mcp-deploy

Penpot's MCP server in multi-user mode, deployed on the personal Dokploy at `penpot-mcp.pavlokostiuk.cloud`, so several Claude sessions can drive different Penpot windows on one account.

The upstream plugin connects without a token in local mode. `penpot-mcp.patch` adds a "Session token" field; each Penpot window connects with its own token, and each Claude session uses the matching `?userToken=`.

| Path | Serves |
|---|---|
| `/manifest.json` | patched plugin, asks for a session token |
| `/a/manifest.json` … `/e/manifest.json` | same plugin with that slot's token baked in; connects on open |
| `/mcp`, `/sse`, `/messages` | MCP server |
| `/ws` | plugin WebSocket |

`penpot-mcp.patch` also hardens background tabs: the plugin heartbeat runs in a Web Worker (page timers are throttled when the tab is hidden) and holds a Web Lock, and the server dispatches tasks to a tab with a stale heartbeat instead of refusing them — a socket message can wake a throttled tab; a timeout then explains the likely cause.

Pinned to penpot `05bd19787c7640553f1c48b369cdee62628c2248` (2.18.1). Bump `PENPOT_COMMIT` in the Dockerfile and re-check the patch applies when Penpot updates.

## Client

```
claude mcp add penpot-a -t http "https://penpot-mcp.pavlokostiuk.cloud/mcp?userToken=<token-a>"
```

A token is a secret: anyone holding one can run code in the Penpot window connected with it. Every route is behind a Traefik IP allowlist (`PENPOT_MCP_ALLOW_IPS`), because `/a` and `/b` serve their tokens to whoever can fetch them.

Dokploy environment: `PENPOT_MCP_TOKEN_A` … `PENPOT_MCP_TOKEN_E` (must equal the `userToken` in the matching Claude MCP server) and `PENPOT_MCP_ALLOW_IPS` (e.g. `203.0.113.7/32`).
