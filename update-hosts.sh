#!/bin/bash

# Gitee仓库中hosts文件的URL
HOSTS_URL="https://gitee.com/liuhaonan66662/available-hosts-within-china/raw/master/hosts.txt"

# 备份文件路径
BACKUP_HOSTS_FILE="/etc/hosts.original"

# 临时文件存储新下载的hosts
TEMP_HOSTS_FILE="/tmp/new_hosts.txt"

# 检查是否是第一次运行
if [ ! -f "$BACKUP_HOSTS_FILE" ]; then
    # 备份原始的hosts文件
    cp /etc/hosts "$BACKUP_HOSTS_FILE"
    echo "$(date): Original hosts file has been backed up." >> /var/log/update-hosts.log
fi

# 下载新的hosts内容
curl -s "$HOSTS_URL" -o "$TEMP_HOSTS_FILE"

# 检查下载是否成功
if [ $? -ne 0 ]; then
    echo "$(date): Failed to download the hosts file." >> /var/log/update-hosts.log
    exit 1
fi

# 使用备份文件和新下载的hosts内容生成最终的hosts文件
{
    cat "$BACKUP_HOSTS_FILE"
    echo ""
    echo "# START OF CUSTOM HOSTS"
    cat "$TEMP_HOSTS_FILE"
    echo "# END OF CUSTOM HOSTS"
} > /etc/hosts

# 检查是否成功更新
if [ $? -eq 0 ]; then
    echo "$(date): Hosts file has been updated successfully." >> /var/log/update-hosts.log
else
    echo "$(date): Failed to update the hosts file." >> /var/log/update-hosts.log
fi

# 清理临时文件
rm -f "$TEMP_HOSTS_FILE"
