#!/bin/bash

# 打印环境变量以进行调试
echo "Environment Variables:"
printenv

# 动态生成 supervisord.conf 文件
cat <<EOF > /etc/supervisor/conf.d/supervisord.conf
[supervisord]
nodaemon=true

[program:cron]
command=cron -f
autostart=true
autorestart=true
stderr_logfile=/var/log/cron.err.log
stdout_logfile=/var/log/cron.out.log

[program:java-app]
command=java $(echo ${JAVA_OPTS}) -Dfile.encoding=utf-8 -Dspring.config.location=/app/config/ org.springframework.boot.loader.JarLauncher
autostart=true
autorestart=true
user=appuser
stderr_logfile=/var/log/java-app.err.log
stdout_logfile=/var/log/java-app.out.log
EOF

# 初始化持久化目录
CONFIG_PATH=/app/config
DATABASE_PATH=/app/database
if [ ! -d "${CONFIG_PATH}" ]; then
  mkdir -p ${CONFIG_PATH}
fi
if [ ! -d "${DATABASE_PATH}" ]; then
  mkdir -p ${DATABASE_PATH}
fi

# 初始化持久化配置
cp -n /app/BOOT-INF/classes/application.yml ${CONFIG_PATH}/application.yml
cp -n /app/BOOT-INF/classes/application-prod.yml ${CONFIG_PATH}/application-prod.yml
cp -n /app/BOOT-INF/classes/database/jproxy.db ${DATABASE_PATH}/jproxy.db

# 设置权限
chown -R appuser:appgroup /app/

# 启动 supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf