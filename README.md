# penpot-mcp-deploy

Penpot's MCP server in multi-user mode, deployed on the personal Dokploy at `penpot-mcp.pavlokostiuk.cloud`, so several Claude sessions can drive different Penpot windows on one account.

The upstream plugin connects without a token in local mode. `plugin-session-token.patch` adds a "Session token" field; each Penpot window connects with its own token, and each Claude session uses the matching `?userToken=`.

| Path | Serves |
|---|---|
| `/manifest.json` | patched plugin (load it in Penpot → Plugins) |
| `/mcp`, `/sse`, `/messages` | MCP server |
| `/ws` | plugin WebSocket |

Pinned to penpot `05bd19787c7640553f1c48b369cdee62628c2248` (2.18.1). Bump `PENPOT_COMMIT` in the Dockerfile and re-check the patch applies when Penpot updates.

## Client

```
claude mcp add penpot-a -t http "https://penpot-mcp.pavlokostiuk.cloud/mcp?userToken=<token-a>"
```

A token is a secret: anyone holding one can run code in the Penpot window connected with it.
