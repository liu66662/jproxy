FROM luckypuppy514/jproxy:latest

# 定义环境变量
ENV PUID=1000
ENV PGID=1000
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# 安装必要的软件并创建用户和组
RUN apt-get update && \
    apt-get install -y cron supervisor && \
    groupadd -g ${PGID} appgroup && \
    useradd -u ${PUID} -g ${PGID} -m appuser && \
    echo "*/30 * * * * root /usr/local/bin/update-hosts.sh >> /var/log/update-hosts.log 2>&1" > /etc/cron.d/update-hosts && \
    chmod 600 /etc/cron.d/update-hosts && \
    touch /var/log/update-hosts.log && chmod 666 /var/log/update-hosts.log && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 添加更新脚本并赋予可执行权限
COPY update-hosts.sh /usr/local/bin/update-hosts.sh
RUN chmod +x /usr/local/bin/update-hosts.sh

# 设置工作目录
WORKDIR /app

# 添加入口点脚本并赋予可执行权限
COPY --chmod=755 entrypoint.sh /app/entrypoint.sh

# 设置默认命令
CMD ["/usr/bin/supervisord"]
