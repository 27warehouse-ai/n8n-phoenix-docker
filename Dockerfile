FROM n8nio/n8n:2.0.3
USER root

# ------------------------------------------------
# 1. 安裝影片處理環境 (Python, FFmpeg) - 保留你原本的設定
# ------------------------------------------------
RUN apk add --no-cache python3 py3-pip git ffmpeg bash curl jq

# 設定 Python 虛擬環境
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip && \
    pip install auto-editor

# ------------------------------------------------
# 2. Zeabur 建議的權限修復 (暴力解鎖版)
# ------------------------------------------------
# 我們建立一個啟動腳本，每次開機時強制把權限改成 777
# 這樣不管是 Root 還是 Node 都能寫入，一勞永逸
# ------------------------------------------------
RUN echo '#!/bin/sh' > /permission-fix.sh && \
    echo 'echo "🔧 [Fix] Fixing permissions for /home/node/.n8n and /data..."' >> /permission-fix.sh && \
    echo 'mkdir -p /home/node/.n8n /data' >> /permission-fix.sh && \
    echo 'chmod -R 777 /home/node/.n8n 2>/dev/null || true' >> /permission-fix.sh && \
    echo 'chmod -R 777 /data 2>/dev/null || true' >> /permission-fix.sh && \
    echo 'echo "✅ Permissions fixed. Starting n8n..."' >> /permission-fix.sh && \
    echo 'exec /docker-entrypoint.sh "$@"' >> /permission-fix.sh && \
    chmod +x /permission-fix.sh

# ------------------------------------------------
# 3. 啟動設定
# ------------------------------------------------
ENTRYPOINT ["/permission-fix.sh"]
CMD ["n8n", "start"]
