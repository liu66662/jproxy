FROM luckypuppy514/jproxy:latest

# 定义 PUID、PGID 和 JAVA_OPTS 环境变量，默认值可以在这里设定或在运行容器时通过 -e 参数覆盖
ENV PUID=1000
ENV PGID=1000
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# 安装 cron 和 supervisord
RUN apt-get update && \
    apt-get install -y cron supervisor && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 创建具有指定 UID 和 GID 的用户和组
RUN groupadd -g ${PGID} appgroup && \
    useradd -u ${PUID} -g ${PGID} -m appuser

# 添加更新脚本，并确保它具有可执行权限
COPY update-hosts.sh /usr/local/bin/update-hosts.sh
RUN chmod +x /usr/local/bin/update-hosts.sh

# 配置 cron 定时任务
RUN echo "* * * * * root /usr/local/bin/update-hosts.sh >> /var/log/update-hosts.log 2>&1" > /etc/cron.d/update-hosts \
    && chmod 644 /etc/cron.d/update-hosts

# 确保日志文件存在，并设置适当的权限
RUN touch /var/log/update-hosts.log && chmod 666 /var/log/update-hosts.log

# 设置工作目录
WORKDIR /app

# 复制 entrypoint 脚本，并确保它具有可执行权限
COPY --chmod=755 entrypoint.sh /app/entrypoint.sh

# 设置入口点
ENTRYPOINT ["/app/entrypoint.sh"]