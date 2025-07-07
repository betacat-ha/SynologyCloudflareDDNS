
# Synology Cloudflare DDNS 脚本 📜

[English](README.md) | 简体中文

这是一个用于将 [Cloudflare](https://www.cloudflare.com/) 作为 DDNS 服务添加到 [Synology](https://www.synology.com/) NAS 的脚本。该脚本使用了更新的 Cloudflare API v4。

## 使用方法

### 通过 SSH 访问 Synology

1. 登录到 DSM
2. 转到 控制面板 > 终端机和SNMP > 启用 SSH 功能
3. 使用客户端通过 SSH 访问 Synology。
4. 使用你的 Synology 管理员账号连接。

### 在 Synology 上运行命令

1. 从本仓库下载 `cloudflareddns.sh` 到 `/sbin/cloudflareddns.sh`：

```
wget https://raw.githubusercontent.com/betacat-ha/SynologyCloudflareDDNS/master/cloudflareddns.sh -O /sbin/cloudflareddns.sh
wget https://raw.githubusercontent.com/betacat-ha/SynologyCloudflareDDNS/master/cloudflareddns-ipv4.sh -O /sbin/cloudflareddns-ipv4.sh
wget https://raw.githubusercontent.com/betacat-ha/SynologyCloudflareDDNS/master/cloudflareddns-ipv6.sh -O /sbin/cloudflareddns-ipv6.sh
```

你可以将脚本放到任何路径。如果你将脚本放在其他路径或命名，请确保使用正确的路径。

1. 赋予脚本执行权限：

```
chmod +x /sbin/cloudflareddns.sh
chmod +x /sbin/cloudflareddns-ipv4.sh
chmod +x /sbin/cloudflareddns-ipv6.sh
```

3. 将 `cloudflareddns.sh` 添加到 Synology：

```
cat >> /etc.defaults/ddns_provider.conf << 'EOF'
[Cloudflare]
        modulepath=/sbin/cloudflareddns.sh
        queryurl=https://www.cloudflare.com
        website=https://www.cloudflare.com
[Cloudflare IPv4 Only]
        modulepath=/sbin/cloudflareddns-ipv4.sh
        queryurl=https://www.cloudflare.com
        website=https://www.cloudflare.com
[Cloudflare IPv6 Only]
        modulepath=/sbin/cloudflareddns-ipv6.sh
        queryurl=https://www.cloudflare.com
        website=https://www.cloudflare.com
E*.
```

`queryurl` 并不重要，因为我们将使用我们的脚本，但它是必需的。

### 获取 Cloudflare 参数

1. 在域名概述页面底部，复制你的区域 ID。
2. 在你的个人资料 > **API 令牌** > **创建令牌**。它应具有 `区域 > DNS > 编辑` 权限。复制 API 令牌。

### 配置 DDNS

1. 登录到你的 DSM
2. 打开 控制面板 > 外部访问 > DDNS > 新增
3. 输入以下信息：
   - 服务供应商：`Cloudflare`/`Cloudflare IPv4 Only`/`Cloudflare IPv6 Only`
   - 主机名称：`www.example.com`
   - 用户名/电子邮件：`<区域 ID>`
   - 密码/密钥：`<API 令牌>`
