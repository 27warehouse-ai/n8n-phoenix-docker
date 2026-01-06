FROM n8nio/n8n:2.0.3
USER root

# ------------------------------------------------
# 1. 安裝影片處理環境 & gosu
# ------------------------------------------------
RUN apk add --no-cache python3 py3-pip git ffmpeg bash curl jq gosu

# 設定 Python 虛擬環境
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip && \
    pip install auto-editor

# ------------------------------------------------
# 2. 確保 node 使用者存在
# ------------------------------------------------
RUN id node || adduser -D -u 1000 node

# ------------------------------------------------
# 3. 預先創建目錄並授權
# ------------------------------------------------
RUN mkdir -p /home/node/.n8n /data && \
    chown -R node:node /home/node/.n8n /data && \
    chmod -R 777 /home/node/.n8n /data

# ------------------------------------------------
# 4. 權限修復與啟動腳本 (終極修正版)
# ------------------------------------------------
RUN cat > /permission-fix.sh << 'EOF'
#!/bin/sh
set -e

echo "🔧 [Fix] Fixing permissions for /home/node/.n8n and /data..."

# 確保目錄存在
mkdir -p /home/node/.n8n /data

# 修正擁有者和權限
chown -R node:node /home/node/.n8n /data
chmod -R 777 /home/node/.n8n /data

echo "✅ Permissions fixed. Starting n8n as node user..."

# 關鍵修正 1：明確宣告 PATH，確保 Python venv 和系統指令都在
export PATH="/opt/venv/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# 關鍵修正 2：使用 gosu 切換身分，並直接呼叫 n8n 絕對路徑
exec gosu node /usr/local/bin/n8n start
EOF

RUN chmod +x /permission-fix.sh

# ------------------------------------------------
# 5. 啟動進入點
# ------------------------------------------------
ENTRYPOINT ["/permission-fix.sh"]
