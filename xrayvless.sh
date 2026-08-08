#!/bin/bash
set -e
#====== 彩色输出函数 (必须放前面) ======
green() { echo -e "\033[32m$1\033[0m"; }
red()   { echo -e "\033[31m$1\033[0m"; }
yellow() { echo -e "\033[33m$1\033[0m"; } 
#====== 安装依赖 ======
detect_os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
  else
    OS=$(uname -s)
  fi
  echo "$OS"
}
OS=$(detect_os)
install_dependencies() {
  green "检测到系统: $OS，安装依赖..."
  case "$OS" in
    ubuntu|debian)
      sudo apt update
      sudo apt install -y curl wget xz-utils jq xxd >/dev/null 2>&1
      ;;
    centos|rhel|rocky|alma)
      sudo yum install -y epel-release
      sudo yum install -y curl wget xz jq vim-common >/dev/null 2>&1
      ;;
    alpine)
      sudo apk update
      sudo apk add --no-cache curl wget xz jq vim bash openssl
      ;;
    *)
      red "不支持的系统: $OS"
      exit 1
      ;;
  esac
}
# 安装前置
install_dependencies

#====== 检测xray是否安装 =====
check_and_install_xray() {
  if command -v xray >/dev/null 2>&1; then
    green "✅ Xray 已安装，跳过安装"
  else
    green "❗检测到 Xray 未安装，正在安装..."
	if [ "$OS" = "alpine" ]; then
		bash <(curl -L https://github.com/Lorry-San/fast-vless/raw/refs/heads/main/xrayinstall-alpine.sh)
	else
		bash <(curl -L https://github.com/Lorry-San/fast-vless/raw/refs/heads/main/xrayinstall.sh)
	fi
    
    XRAY_BIN=$(command -v xray || echo "/usr/local/bin/xray")
    if [ ! -x "$XRAY_BIN" ]; then
      red "❌ Xray 安装失败，请检查"
      exit 1
    fi
    green "✅ Xray 安装完成"
  fi
}
#====== 流媒体解锁检测 ======
check_streaming_unlock() {
  bash <(curl -L ip.check.place) -y
  read -rp "按任意键返回菜单..."
}

#====== IP 纯净度检测 ======
check_ip_clean() {
  bash <(curl -L ip.check.place) -y
  read -rp "按任意键返回菜单..."
}

install_trojan_reality() {
  check_and_install_xray
  XRAY_BIN=$(command -v xray || echo "/usr/local/bin/xray")
  read -rp "监听端口（如 443）: " PORT
  read -rp "节点备注（如：trojanNode）: " REMARK

  PASSWORD=$(openssl rand -hex 8)
  KEYS=$($XRAY_BIN x25519)
  PRIV_KEY=$(echo "$KEYS" | awk '/PrivateKey:/ {print $2}')
  PUB_KEY=$(echo "$KEYS" | awk '/Password/ {print $2}')
  SHORT_ID=$(head -c 4 /dev/urandom | xxd -p)
  SNI="icloud.cdn-apple.com"

  mkdir -p /usr/local/etc/xray
  cat > /usr/local/etc/xray/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [{
    "port": $PORT,
    "protocol": "trojan",
    "settings": {
      "clients": [{ "password": "$PASSWORD", "email": "$REMARK"}]
    },
    "streamSettings": {
      "network": "tcp",
      "security": "reality",
      "realitySettings": {
        "show": false,
        "dest": "$SNI:443",
        "xver": 0,
        "serverNames": ["$SNI"],
        "privateKey": "$PRIV_KEY",
        "shortIds": ["$SHORT_ID"]
      }
    }
  }],
  "outbounds": [{ "protocol": "freedom" }]
}
EOF

  if [ "$OS" = "alpine" ]; then
      rc-service xray restart
      rc-update add xray default
  else
      systemctl daemon-reexec
      systemctl restart xray
      systemctl enable xray
  fi
  IP=$(curl -s ipv4.ip.sb || curl -s ifconfig.me)
  LINK="trojan://$PASSWORD@$IP:$PORT?security=reality&sni=$SNI&pbk=$PUB_KEY&sid=$SHORT_ID&type=tcp&headerType=none#$REMARK"
  green "✅ Trojan Reality 节点链接如下："
  echo "$LINK"
  read -rp "按任意键返回菜单..."
}
#====== 主菜单 ======
while true; do
  clear
  green "AD：优秀流媒体便宜LXC小鸡：伤心的云 sadidc.cn"
  green "AD: 大量优秀解锁 & 优化线路KVM: 光锥云 lightcone.hk"
  green "======= VLESS Reality 一键脚本V6.1正式版 by Lorry-San（💩山Pro Max） ======="
  echo "1) 安装并配置 VLESS Reality Vision节点"  
  echo "2）生成Trojan Reality节点"
  echo "3) 生成 VLESS 中转链接"
  echo "4) 开启 BBR 加速"
  echo "5) 检查 IP 纯净度 & 流媒体解锁"
  echo "6) Ookla Speedtest 测试"
  echo "7) 卸载 Xray"
  echo "0) 退出"
  echo
  read -rp "请选择操作: " choice

  case "$choice" in
    1)
      check_and_install_xray
      XRAY_BIN=$(command -v xray || echo "/usr/local/bin/xray")
      read -rp "监听端口（如 443）: " PORT
      read -rp "节点备注: " REMARK
      UUID=$(cat /proc/sys/kernel/random/uuid)
      KEYS=$($XRAY_BIN x25519)
      PRIV_KEY=$(echo "$KEYS" | awk '/PrivateKey:/ {print $2}')
      PUB_KEY=$(echo "$KEYS" | awk '/Password/ {print $2}')
      SHORT_ID=$(head -c 4 /dev/urandom | xxd -p)
      SNI="music.apple.com"

      mkdir -p /usr/local/etc/xray
      cat > /usr/local/etc/xray/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [{
    "port": $PORT,
    "protocol": "vless",
    "settings": {
      "clients": [{ "id": "$UUID", "email": "$REMARK" , "flow": "xtls-rprx-vision"}],
      "decryption": "none"
    },
    "streamSettings": {
      "network": "tcp",
      "security": "reality",
      "realitySettings": {
        "show": false,
        "dest": "$SNI:443",
        "xver": 0,
        "serverNames": ["$SNI"],
        "privateKey": "$PRIV_KEY",
        "shortIds": ["$SHORT_ID"]
      }
    }
  }],
  "outbounds": [{ "protocol": "freedom" }]
}
EOF

	  if [ "$OS" = "alpine" ]; then
	      rc-service xray restart
	      rc-update add xray default
	  else
	      systemctl daemon-reexec
          systemctl restart xray
          systemctl enable xray
	  fi
      IP=$(curl -s ipv4.ip.sb || curl -s ifconfig.me)
      LINK="vless://$UUID@$IP:$PORT?type=tcp&security=reality&flow=xtls-rprx-vision&sni=$SNI&fp=chrome&pbk=$PUB_KEY&sid=$SHORT_ID#$REMARK"
      green "✅ 节点链接如下："
      echo "$LINK"
      read -rp "按任意键返回菜单..."
      ;;
    2)
      install_trojan_reality
      ;;
    3)
      read -rp "请输入原始 VLESS 链接: " old_link
      read -rp "请输入中转服务器地址（IP 或域名）: " new_server
      new_link=$(echo "$old_link" | sed -E "s#(@)[^:]+#\\1$new_server#")
      green "🎯 生成的新中转链接："
      echo "$new_link"
      read -rp "按任意键返回菜单..."
      ;;

    4)
	  cat > /etc/sysctl.conf << EOF
fs.file-max = 6815744
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_ecn=0
net.ipv4.tcp_frto=0
net.ipv4.tcp_mtu_probing=0
net.ipv4.tcp_rfc1337=0
net.ipv4.tcp_sack=1
net.ipv4.tcp_fack=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_adv_win_scale=1
net.ipv4.tcp_moderate_rcvbuf=1
net.core.rmem_max=33554432
net.core.wmem_max=33554432
net.ipv4.tcp_rmem=4096 87380 33554432
net.ipv4.tcp_wmem=4096 16384 33554432
net.ipv4.udp_rmem_min=8192
net.ipv4.udp_wmem_min=8192
net.ipv4.ip_forward=1
net.ipv4.conf.all.route_localnet=1
net.ipv4.conf.all.forwarding=1
net.ipv4.conf.default.forwarding=1
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv6.conf.all.forwarding=1
net.ipv6.conf.default.forwarding=1
EOF
	  sysctl -p && sysctl --system
      green "✅ BBR 加速已启用"
      read -rp "按任意键返回菜单..."
      ;;

    5)
      check_streaming_unlock
      ;;

    6)
      wget -q https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz
      tar -zxf ookla-speedtest-1.2.0-linux-x86_64.tgz
      chmod +x speedtest
      ./speedtest --accept-license --accept-gdpr
      rm -f speedtest speedtest.5 speedtest.md ookla-speedtest-1.2.0-linux-x86_64.tgz
      read -rp "按任意键返回菜单..."
      ;;

    7)
      if [ "$OS" = "alpine" ]; then
	   	rc-service xray stop
        rc-update del xray
	  else
	  	systemctl stop xray
        systemctl disable xray
	  fi
      
      
      rm -rf /usr/local/etc/xray /usr/local/bin/xray
      green "✅ Xray 已卸载"
      read -rp "按任意键返回菜单..."
      ;;

    0)
      exit 0
      ;;

    *)
      red "❌ 无效选项，请重试"
      sleep 1
      ;;
  esac
done
