FROM node:22-alpine AS build
RUN apk add --no-cache git && corepack enable
ARG PENPOT_COMMIT=05bd19787c7640553f1c48b369cdee62628c2248
ARG WS_URI
ARG TOKEN_A=
ARG TOKEN_B=
ARG TOKEN_C=
ARG TOKEN_D=
ARG TOKEN_E=
WORKDIR /src
RUN git clone -q --filter=blob:none --sparse --no-checkout https://github.com/penpot/penpot.git . \
 && git sparse-checkout set mcp \
 && git checkout -q "$PENPOT_COMMIT"
COPY penpot-mcp.patch /tmp/
RUN git apply /tmp/penpot-mcp.patch
WORKDIR /src/mcp
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0 WS_URI=$WS_URI
RUN pnpm -r install --frozen-lockfile && pnpm run build
WORKDIR /src/mcp/packages/plugin
RUN for slot in a b c d e; do \
      token="$(eval echo "\$TOKEN_$(echo "$slot" | tr a-z A-Z)")"; \
      BAKED_TOKEN="$token" ./node_modules/.bin/vite build --config vite.release.config.ts --outDir "dist-$slot" \
      && sed -i "s/\"Penpot MCP Plugin\"/\"Penpot MCP ($slot)\"/" "dist-$slot/manifest.json"; \
    done

FROM node:22-alpine AS server
WORKDIR /app
COPY --from=build /src/mcp /app
WORKDIR /app/packages/server
ENV PENPOT_MCP_SERVER_HOST=0.0.0.0 PENPOT_MCP_REMOTE_MODE=true NODE_ENV=production
EXPOSE 4401 4402
CMD ["node", "dist/index.js", "--multi-user"]

FROM nginx:1.29-alpine AS plugin
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /src/mcp/packages/plugin/dist /usr/share/nginx/html
COPY --from=build /src/mcp/packages/plugin/dist-a /usr/share/nginx/html/a
COPY --from=build /src/mcp/packages/plugin/dist-b /usr/share/nginx/html/b
COPY --from=build /src/mcp/packages/plugin/dist-c /usr/share/nginx/html/c
COPY --from=build /src/mcp/packages/plugin/dist-d /usr/share/nginx/html/d
COPY --from=build /src/mcp/packages/plugin/dist-e /usr/share/nginx/html/e
