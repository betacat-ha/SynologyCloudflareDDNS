# Synology Cloudflare DDNS Script 📜

English | [简体中文](README-ZH-CN.md)

The is a script to be used to add [Cloudflare](https://www.cloudflare.com/) as a DDNS to [Synology](https://www.synology.com/) NAS. The script used an updated API, Cloudflare API v4.

## How to use

### Access Synology via SSH

1. Login to your DSM
2. Go to Control Panel > Terminal & SNMP > Enable SSH service
3. Use your client to access Synology via SSH.
4. Use your Synology admin account to connect.

### Run commands in Synology

1. Download `cloudflareddns.sh` from this repository to `/sbin/cloudflareddns.sh`

```
wget https://raw.githubusercontent.com/betacat-ha/SynologyCloudflareDDNS/master/cloudflareddns.sh -O /sbin/cloudflareddns.sh
wget https://raw.githubusercontent.com/betacat-ha/SynologyCloudflareDDNS/master/cloudflareddns-ipv4.sh -O /sbin/cloudflareddns-ipv4.sh
wget https://raw.githubusercontent.com/betacat-ha/SynologyCloudflareDDNS/master/cloudflareddns-ipv6.sh -O /sbin/cloudflareddns-ipv6.sh
```

It is not a must, you can put I whatever you want. If you put the script in other name or path, make sure you use the right path.

2. Give others execute permission

```
chmod +x /sbin/cloudflareddns.sh
chmod +x /sbin/cloudflareddns-ipv4.sh
chmod +x /sbin/cloudflareddns-ipv6.sh
```

3. Add `cloudflareddns.sh` to Synology

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

`queryurl` does not matter because we are going to use our script but it is needed.

### Get Cloudflare parameters

1. Go to your domain overview page and copy your zone ID.
2. Go to your profile > **API Tokens** > **Create Token**. It should have the permissions of `Zone > DNS > Edit`. Copy the api token.

### Setup DDNS

1. Login to your DSM
2. Go to Control Panel > External Access > DDNS > Add
3. Enter the following:
   - Service provider: `Cloudflare`/`Cloudflare IPv4 Only`/`Cloudflare IPv6 Only`
   - Hostname: `www.example.com`
   - Username/Email: `<Zone ID>`
   - Password Key: `<API Token>`
