#!/bin/bash

# 启动 cron 服务（前台运行）
service cron start || true

# 执行原始的 entrypoint.sh
exec /app/entrypoint.sh