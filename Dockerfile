FROM n8nio/n8n:2.0.3
USER root

# ------------------------------------------------
# 1. 安裝影片處理環境
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
# 3. 創建必要的目錄並設置正確的擁有者
# ------------------------------------------------
RUN mkdir -p /home/node/.n8n /data && \
    chown -R node:node /home/node/.n8n /data && \
    chmod -R 777 /home/node/.n8n /data

# ------------------------------------------------
# 4. 權限修復腳本 - 完整修正版本
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

# 關鍵修正：保留 PATH 環境變數並以 node 使用者身份執行
# 使用完整路徑確保 n8n 命令能被找到
export PATH="/opt/venv/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
exec gosu node /usr/local/bin/n8n start
EOF

RUN chmod +x /permission-fix.sh

# ------------------------------------------------
# 5. 啟動設定
# ------------------------------------------------
ENTRYPOINT ["/permission-fix.sh"]
