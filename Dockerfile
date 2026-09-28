FROM node:22-alpine AS build
RUN apk add --no-cache git && corepack enable
ARG PENPOT_COMMIT=05bd19787c7640553f1c48b369cdee62628c2248
ARG WS_URI
WORKDIR /src
RUN git clone -q --filter=blob:none --sparse --no-checkout https://github.com/penpot/penpot.git . \
 && git sparse-checkout set mcp \
 && git checkout -q "$PENPOT_COMMIT"
COPY plugin-session-token.patch /tmp/
RUN git apply /tmp/plugin-session-token.patch
WORKDIR /src/mcp
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0 WS_URI=$WS_URI
RUN pnpm -r install --frozen-lockfile && pnpm run build

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
