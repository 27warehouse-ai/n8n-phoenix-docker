# 依照您的要求，維持使用 2.0.3 版本
FROM n8nio/n8n:2.0.3
USER root

# ------------------------------------------------
# 1. 安裝影片處理環境
# ------------------------------------------------
RUN apk add --no-cache python3 py3-pip git ffmpeg bash curl jq

# 設定 Python 虛擬環境
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip && \
    pip install auto-editor

# ------------------------------------------------
# 2. Zeabur 權限修復腳本
# ------------------------------------------------
RUN echo '#!/bin/sh' > /permission-fix.sh && \
    echo 'echo "🔧 [Fix] Fixing permissions for /home/node/.n8n and /data..."' >> /permission-fix.sh && \
    echo 'mkdir -p /home/node/.n8n /data' >> /permission-fix.sh && \
    # 增加擁有者設定，減少權限問題
    echo 'chown -R node:node /home/node/.n8n /data' >> /permission-fix.sh && \
    echo 'chmod -R 777 /home/node/.n8n /data' >> /permission-fix.sh && \
    echo 'echo "✅ Permissions fixed. Starting n8n..."' >> /permission-fix.sh && \
    # 這裡呼叫原始 entrypoint
    echo 'exec /docker-entrypoint.sh "$@"' >> /permission-fix.sh && \
    chmod +x /permission-fix.sh

# ------------------------------------------------
# 3. 啟動設定
# ------------------------------------------------
ENTRYPOINT ["/permission-fix.sh"]

# 🔴 關鍵修正：
# 即使是 2.0.3 版，經過 Python 環境設定後 PATH 也可能跑掉
# 使用絕對路徑是解決 "Command not found" 最安全的方法
CMD ["/usr/local/bin/n8n", "start"]
