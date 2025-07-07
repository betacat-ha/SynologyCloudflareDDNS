#!/bin/bash
set -euo pipefail

# 参数解析
username="$1"     # zone ID
password="$2"     # Bearer token
hostname="$3"     # 要更新的域名，例如：example.com
interface="ovs_eth0"  # 网卡名，默认 ovs_eth0

# === 获取公网 IPv6 地址（带 global scope 且合法前缀）===
get_ipv6_address() {
    while read -r ip; do
        prefix=$(echo "$ip" | cut -d: -f1)
        prefix_int=$((16#$prefix))
        if (( prefix_int >= 0x2000 && prefix_int <= 0x3fff )); then
            echo "$ip"
            return 0
        fi
    done < <(ip -6 addr show "$interface" | awk '/inet6.*scope global/ {print $2}' | cut -d/ -f1)

    return 1
}

ip6Addr=$(get_ipv6_address || true)

if [[ -z "$ip6Addr" ]]; then
    # 无法获取 IPv6 地址，终止
    exit 1
fi

recordType="AAAA"

# 查询当前记录
listApi="https://api.cloudflare.com/client/v4/zones/${username}/dns_records?type=${recordType}&name=${hostname}"

res=$(curl -s -X GET "$listApi" \
    -H "Authorization: Bearer $password" \
    -H "Content-Type: application/json")

resSuccess=$(echo "$res" | jq -r ".success")

if [[ "$resSuccess" != "true" ]]; then
    # Cloudflare API 查询失败
    echo "badauth";
    exit 1
fi

recordId=$(echo "$res" | jq -r ".result[0].id")
recordIp=$(echo "$res" | jq -r ".result[0].content")
recordProx=$(echo "$res" | jq -r ".result[0].proxied")

createApi="https://api.cloudflare.com/client/v4/zones/${username}/dns_records"
updateApi="https://api.cloudflare.com/client/v4/zones/${username}/dns_records/${recordId}"

# 判断是否需要更新
if [[ "$recordIp" == "$ip6Addr" ]]; then
    # IPv6 无变更，跳过更新。
    echo "nochg"
    exit 0
fi

# 创建或更新记录
if [[ "$recordId" == "null" ]]; then
    # 记录不存在，创建
    proxy="true"
    res=$(curl -s -X POST "$createApi" \
        -H "Authorization: Bearer $password" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"$recordType\",\"name\":\"$hostname\",\"content\":\"$ip6Addr\",\"proxied\":$proxy}")
else
    # 记录存在，更新
    res=$(curl -s -X PUT "$updateApi" \
        -H "Authorization: Bearer $password" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"$recordType\",\"name\":\"$hostname\",\"content\":\"$ip6Addr\",\"proxied\":$recordProx}")
fi

resUpdateSuccess=$(echo "$res" | jq -r ".success")

if [[ "$resUpdateSuccess" == "true" ]]; then
    echo "good"
    exit 0
else
    echo "badauth"
    exit 1
fi
