#!/bin/bash
set -euo pipefail

# 参数解析
username="$1"     # zone ID
password="$2"     # Bearer token
hostname="$3"     # 要更新的域名
ip4Addr="$4"      # 由群晖提供的 IPv4 地址

recordType="A"

# 查询当前记录
listApi="https://api.cloudflare.com/client/v4/zones/${username}/dns_records?type=${recordType}&name=${hostname}"

res=$(curl -s -X GET "$listApi" \
    -H "Authorization: Bearer $password" \
    -H "Content-Type: application/json")

resSuccess=$(echo "$res" | jq -r ".success")

if [[ "$resSuccess" != "true" ]]; then
    echo "badauth"
    exit 1
fi

recordId=$(echo "$res" | jq -r ".result[0].id")
recordIp=$(echo "$res" | jq -r ".result[0].content")
recordProx=$(echo "$res" | jq -r ".result[0].proxied")

createApi="https://api.cloudflare.com/client/v4/zones/${username}/dns_records"
updateApi="https://api.cloudflare.com/client/v4/zones/${username}/dns_records/${recordId}"

# 判断是否需要更新
if [[ "$recordIp" == "$ip4Addr" ]]; then
    echo "nochg"
    exit 0
fi

# 创建或更新记录
if [[ "$recordId" == "null" ]]; then
    proxy="true"
    res=$(curl -s -X POST "$createApi" \
        -H "Authorization: Bearer $password" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"$recordType\",\"name\":\"$hostname\",\"content\":\"$ip4Addr\",\"proxied\":$proxy}")
else
    res=$(curl -s -X PUT "$updateApi" \
        -H "Authorization: Bearer $password" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"$recordType\",\"name\":\"$hostname\",\"content\":\"$ip4Addr\",\"proxied\":$recordProx}")
fi

resUpdateSuccess=$(echo "$res" | jq -r ".success")

if [[ "$resUpdateSuccess" == "true" ]]; then
    echo "good"
    exit 0
else
    echo "badauth"
    exit 1
fi