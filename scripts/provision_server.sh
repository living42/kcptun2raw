#!/bin/sh
set -e

if [ `whoami` != root ]
then
    echo 'run this script as root'
    exit 1
fi

mode=faketcp
key=foobarx
port=3336
kcp_mode=fast2
kcp_mtu=1200

while getopts m:k:p:n opt
do
    case "$opt" in
        m)
            mode="$OPTARG"
            ;;
        k)
            key="$OPTARG"
            ;;
        p)
            port="$OPTARG"
            ;;
        n)
            kcp_mode="$OPTARGS"
            ;;
    esac
done

apt-get update
apt-get install -y supervisor software-properties-common
add-apt-repository ppa:max-c-lv/shadowsocks-libev -y
apt-get update
apt-get install shadowsocks-libev -y

mkdir /root/kcptun2raw || true
cd /root/kcptun2raw

export KCPTUN_VERSION=20171113

wget -O kcptun-linux-amd64-${KCPTUN_VERSION}.tar.gz \
https://github.com/xtaci/kcptun/releases/download/v20171113/kcptun-linux-amd64-${KCPTUN_VERSION}.tar.gz
mkdir /tmp/kcptun || true
tar xzf kcptun-linux-amd64-${KCPTUN_VERSION}.tar.gz -C /tmp/kcptun
install /tmp/kcptun/server_linux_amd64 /usr/local/bin/kcptun-server
rm -rf /tmp/kcptun

export UDP2RAW_VERSION=20171111.0

wget -O udp2raw_binaries-${UDP2RAW_VERSION}.tar.gz https://github.com/wangyu-/udp2raw-tunnel/releases/download/${UDP2RAW_VERSION}/udp2raw_binaries.tar.gz
mkdir /tmp/udp2raw || true
tar xzf udp2raw_binaries-${UDP2RAW_VERSION}.tar.gz -C /tmp/udp2raw
install /tmp/udp2raw/udp2raw_amd64_hw_aes /usr/local/bin/udp2raw
rm -rf /tmp/udp2raw

cat <<EOF > /etc/supervisor/conf.d/kcptun2raw.conf
[program:kcptun2raw-udp2raw-server]
command = udp2raw -s --raw-mode faketcp -a -l 0.0.0.0:$port -r 127.0.0.1:3335 --key $key --disable-color
redirect_stderr = true

[program:kcptun2raw-kcptun-server]
command = kcptun-server --nocomp --crypt none --mode $kcp_mode --listen 127.0.0.1:3335 --target 127.0.0.1:3334 --mtu 1200
redirect_stderr = true

[program:kcptun2raw-shadowsocks-server]
command = ss-server -s 127.0.0.1 -p 3334 -m aes-128-gcm -k foobarx
redirect_stderr = true

[group:kcptun2raw]
programs = kcptun2raw-udp2raw-server,kcptun2raw-kcptun-server,kcptun2raw-shadowsocks-server
EOF

supervisorctl update kcptun2raw
supervisorctl restart kcptun2raw:*

clear

default_route_interface=`ip route | sed -n 's/default.*dev \(\w\{1,\}\).*/\1/p'`
public_addr=`ifconfig $default_route_interface | sed -n 's/.*inet addr:\(\S\{1,\}\).*/\1/p'`

cat <<EOF
udp2raw.conf:

--raw-mode $mode
-r $public_addr:$port
--key $key

kcptun.conf:

{
  "mode": "$kcp_mode",
  "mtu": "$kcp_mtu"
}

EOF

