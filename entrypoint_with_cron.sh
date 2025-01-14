#!/bin/bash

# 启动时立即执行 update-hosts.sh
echo "Executing update-hosts.sh on container start..."
/usr/local/bin/update-hosts.sh

# 启动 cron 服务（前台运行）
echo "Starting cron service..."
service cron start || true

# 执行原始的 entrypoint.sh
exec /app/entrypoint.sh
