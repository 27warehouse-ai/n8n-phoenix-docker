FROM n8nio/n8n:2.0.3
USER root

# ------------------------------------------------
# 1. 安裝影片處理環境 & gosu 工具
# ------------------------------------------------
# 這裡加入了 gosu，這是切換使用者的關鍵工具
RUN apk add --no-cache python3 py3-pip git ffmpeg bash curl jq gosu

# 設定 Python 虛擬環境
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip && \
    pip install auto-editor

# ------------------------------------------------
# 2. 確保 node 使用者存在 (預防性措施)
# ------------------------------------------------
RUN id node || adduser -D -u 1000 node

# ------------------------------------------------
# 3. 預先創建目錄
# ------------------------------------------------
RUN mkdir -p /home/node/.n8n /data && \
    chown -R node:node /home/node/.n8n /data && \
    chmod -R 777 /home/node/.n8n /data

# ------------------------------------------------
# 4. 權限修復腳本 (使用 Zeabur 建議的 gosu 版本)
# ------------------------------------------------
# 這裡使用 cat << EOF 的寫法比較整潔，不易出錯
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

# 關鍵修正：
# 1. 使用 gosu node -> 切換成 node 使用者執行
# 2. 呼叫官方 entrypoint
exec gosu node /docker-entrypoint.sh "$@"
EOF

RUN chmod +x /permission-fix.sh

# ------------------------------------------------
# 5. 啟動設定
# ------------------------------------------------
ENTRYPOINT ["/permission-fix.sh"]

# 使用絕對路徑，確保一定找得到 n8n
CMD ["/usr/local/bin/n8n", "start"]
