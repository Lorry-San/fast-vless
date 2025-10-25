#!/bin/bash
set -e
apk add --no-cache curl unzip
XRAY_VERSION=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip
unzip /tmp/xray.zip -d /tmp/xray
mv /tmp/xray/xray /usr/local/bin/
chmod +x /usr/local/bin/xray
mkdir -p /usr/local/etc/xray
rm -rf /tmp/xray /tmp/xray.zip
cat > /etc/init.d/xray <<'EOF'
#!/sbin/openrc-run

command="/usr/local/bin/xray"
command_args="run -c /usr/local/etc/xray/config.json"
command_background=true
pidfile="/run/${RC_SVCNAME}.pid"

depend() {
    need net
    after firewall
}
EOF

# 设置权限
chmod +x /etc/init.d/xray
rc-update add xray default
rc-service xray start
