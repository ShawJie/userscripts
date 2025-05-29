FROM alpine:3.21.3

WORKDIR /data

RUN apk update && apk add git curl jq python3 nodejs npm python3-dev gcc musl-dev && \
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    git clone https://github.com/SecretiveShell/MCP-Bridge.git bridge && \
    ln -sf ~/.local/bin/uv /usr/local/bin/uv && \
    ln -sf ~/.local/bin/uvx /usr/local/bin/uvx && \
    cd bridge && uv sync

COPY bin /data/bin

ENTRYPOINT [ "sh", "bin/entrypoint.sh" ]
