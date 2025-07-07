#!/bin/bash
set -euo pipefail

# 参数解析
username="$1"     # zone ID
password="$2"     # Bearer token
hostname="$3"     # 要更新的域名
ip4Addr="$4"      # 由群晖提供的 IPv4 地址

# 更新 IPv4 地址
if [[ -n "$ip4Addr" ]]; then
    ./update_ipv4.sh "$username" "$password" "$hostname" "$ip4Addr"
    ipv4_status=$?
else
    # 未提供 IPv4 地址，跳过更新
    ipv4_status=1
fi

# 获取并更新 IPv6 地址
./update_ipv6.sh "$username" "$password" "$hostname"
ipv6_status=$?

# 判断更新结果
if [[ "$ipv4_status" -eq 0 ]] && [[ "$ipv6_status" -eq 0 ]]; then
    echo "good"
    exit 0
else
    echo "badauth"
    exit 1
fi
