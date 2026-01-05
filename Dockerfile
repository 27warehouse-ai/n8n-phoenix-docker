FROM n8nio/n8n:2.0.3

USER root

# 安裝 Python, FFmpeg 和必要工具
RUN apk add --no-cache \
    python3 \
    py3-pip \
    git \
    ffmpeg \
    bash \
    curl \
    jq

# (選用) 建立虛擬環境並安裝 Auto-Editor
# 這是為了避開新版 Python 的 PEP 668 限制
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip && \
    pip install auto-editor

# 建立資料夾權限
RUN mkdir -p /data/shared && \
    chown -R node:node /data/shared && \
    chmod -R 777 /data/shared

USER node
