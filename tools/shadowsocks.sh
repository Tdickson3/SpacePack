#!/usr/bin/env bash
#
#   ██████  ██▓███   ▄▄▄       ▄████▄  ▓█████  ██▓███   ▄▄▄       ▄████▄   ██ ▄█▀       ██████  ██░ ██ 
# ▒██    ▒ ▓██░  ██▒▒████▄    ▒██▀ ▀█  ▓█   ▀ ▓██░  ██▒▒████▄    ▒██▀ ▀█   ██▄█▒      ▒██    ▒ ▓██░ ██▒
# ░ ▓██▄   ▓██░ ██▓▒▒██  ▀█▄  ▒▓█    ▄ ▒███   ▓██░ ██▓▒▒██  ▀█▄  ▒▓█    ▄ ▓███▄░      ░ ▓██▄   ▒██▀▀██░
#   ▒   ██▒▒██▄█▓▒ ▒░██▄▄▄▄██ ▒▓▓▄ ▄██▒▒▓█  ▄ ▒██▄█▓▒ ▒░██▄▄▄▄██ ▒▓▓▄ ▄██▒▓██ █▄        ▒   ██▒░▓█ ░██ 
# ▒██████▒▒▒██▒ ░  ░ ▓█   ▓██▒▒ ▓███▀ ░░▒████▒▒██▒ ░  ░ ▓█   ▓██▒▒ ▓███▀ ░▒██▒ █▄ ██▓ ▒██████▒▒░▓█▒░██▓
# ▒ ▒▓▒ ▒ ░▒▓▒░ ░  ░ ▒▒   ▓▒█░░ ░▒ ▒  ░░░ ▒░ ░▒▓▒░ ░  ░ ▒▒   ▓▒█░░ ░▒ ▒  ░▒ ▒▒ ▓▒ ▒▓▒ ▒ ▒▓▒ ▒ ░ ▒ ░░▒░▒
# ░ ░▒  ░ ░░▒ ░       ▒   ▒▒ ░  ░  ▒    ░ ░  ░░▒ ░       ▒   ▒▒ ░  ░  ▒   ░ ░▒ ▒░ ░▒  ░ ░▒  ░ ░ ▒ ░▒░ ░
# ░  ░  ░  ░░         ░   ▒   ░           ░   ░░         ░   ▒   ░        ░ ░░ ░  ░   ░  ░  ░   ░  ░░ ░
#       ░                 ░  ░░ ░         ░  ░               ░  ░░ ░      ░  ░     ░        ░   ░  ░  ░
#                            ░                                  ░                 ░                    
# Filename:     shadowsocks.sh
# Description:  Shadowsocks server for SpacePack
# Author:       Vtrois <seaton@vtrois.com>
# Project URL:  https://spacepack.sh
# Github URL:   https://github.com/Vtrois/SpacePack
# License:      GPLv3

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

RGB_DANGER='🚨 \033[31;1m'
RGB_WAIT='⏳ \033[37;2m'
RGB_SUCCESS='✨ \033[32m'
RGB_WARNING='💡 \033[33;1m'
RGB_INFO='📋 \033[36;1m'
RGB_END='\033[0m'
PASSWORD=$( cat /dev/urandom | head -n 10 | md5sum | head -c 15 )
SSPORT=$( shuf -i 1024-65535 -n 1 )
BASE=$( pwd )
LOCK=/tmp/sp_shadowsocks.log
SHADOWSOCKSURL="https://github.com/shadowsocks/shadowsocks/archive/master.zip"
LIBSODIUMURL="https://github.com/jedisct1/libsodium/releases/download/1.0.16/libsodium-1.0.16.tar.gz"
ENCRYPTIONS=(
"aes-128-gcm"
"aes-192-gcm"
"aes-256-gcm"
"aes-128-cfb"
"aes-192-cfb"
"aes-256-cfb"
"aes-128-ctr"
"aes-192-ctr"
"aes-256-ctr"
"camellia-128-cfb"
"camellia-192-cfb"
"camellia-256-cfb"
"bf-cfb"
"chacha20-ietf-poly1305"
"salsa20"
"chacha20"
"chacha20-ietf"
"rc4-md5"
)

tool_info() {
    echo -e "==========================================================================================="
    echo -e "                             Shadowsocks server for SpacePack                              "
    echo -e "                  For more information please visit https://spacepack.sh                   "
    echo -e "==========================================================================================="
}

show_help() {
    version
    echo -e "\nUsage: $0 [OPTION]"
    echo -e "\nOption:"
    echo -e "  -i,  --install          install the shadowsocks server."
    echo -e "  -u,  --uninstall        uninstall the shadowsocks server."
    echo -e "  -v,  --version          show the version info."
    echo -e "  -h,  --help             print this help."
    echo -e "\nMail bug reports and suggestions to <seaton@vtrois.com>."
}

version() {
  echo "Shadowsocks server version 1.0"
}

check_root(){
    if [[ $EUID -ne 0 ]]; then
       echo -e "${RGB_DANGER}The script must be run as root!${RGB_END}"
       exit 1
    fi
}

check_lock() {
    if [ -f "$LOCK" ];then
    echo -e "\n${RGB_DANGER}The shadowsocks server has been installed, please use $0 -h to consult the help.${RGB_END}"
    exit 1
    else
    touch $LOCK
    fi
}

check_os() {
    if [ -f /etc/redhat-release ]; then
        RELEASE="centos"
    elif cat /etc/issue | grep -Eqi "debian"; then
        RELEASE="debian"
    elif cat /etc/issue | grep -Eqi "ubuntu"; then
        RELEASE="ubuntu"
    elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
        RELEASE="centos"
    elif cat /proc/version | grep -Eqi "debian"; then
        RELEASE="debian"
    elif cat /proc/version | grep -Eqi "ubuntu"; then
        RELEASE="ubuntu"
    elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
        RELEASE="centos"
    else
        RELEASE="unknown"
    fi
    if [ "${RELEASE}" == "ubuntu" ] || [ "${RELEASE}" == "debian" ];then
        for PACKAGE in wget curl python python-dev python-setuptools openssl libssl-dev unzip gcc automake autoconf make libtool build-essential
        do
            apt-get -y update >> ${LOCK} 2>&1
            apt-get -y install ${PACKAGE} >> ${LOCK} 2>&1
        done
    elif [ "${RELEASE}" = "centos" ];then
        CENTOSVERSION=$( rpm -q centos-release | cut -d- -f3 )
        if [ "${CENTOSVERSION}" != "5" ];then
            for PACKAGE in wget curl python python-devel python-setuptools openssl openssl-devel unzip gcc automake autoconf make libtool
            do
                yum -y update >> ${LOCK} 2>&1
                yum -y install ${PACKAGE} >> ${LOCK} 2>&1
            done
        else
            echo -e "${RGB_DANGER}The system version needs to be more than Centos 6.x!${RGB_END}"
            exit 1
        fi
    else
        echo -e "${RGB_DANGER}The script does not support your OS!${RGB_END}"
        exit 1
    fi
    cd ${BASE}
    if ! wget --no-check-certificate -O shadowsocks-master.zip ${SHADOWSOCKSURL} >> ${LOCK} 2>&1; then
        echo -e "${RGB_DANGER}Failed to download shadowsocks file on Github!${RGB_END}"
        exit 1
    fi
    if ! wget --no-check-certificate -O libsodium-1.0.16.tar.gz ${LIBSODIUMURL} >> ${LOCK} 2>&1; then
        echo -e "${RGB_DANGER}Failed to download libsodium file on Github!${RGB_END}"
        exit 1
    fi
}

public_ip() {
    local IP=$( wget -qO- -t1 -T2 ipv4.icanhazip.com )
    [ -z ${IP} ] && IP=$( curl ip.cip.cc )
    [ ! -z "${IP}" ] && echo ${IP} || echo -e "${RGB_DANGER}Unknown${RGB_END}"
}

install_module() {
    echo -e "\n${RGB_INFO}1/5 : Check and install the necessary module${RGB_END}"
    echo -en "${RGB_WAIT}Checking (probably for a long time)...${RGB_END}"
    check_os
    echo -e "\r${RGB_SUCCESS}Success, the script is ready to be installed!${RGB_END}"
}

ppe_conf() {
    echo -en "\n${RGB_INFO}2/5 : Please input a password (Default is ${PASSWORD}):${RGB_END}"
    read NPASSWORD
    [ -z "${NPASSWORD}" ] && NPASSWORD=${PASSWORD}
    echo -e "${RGB_SUCCESS}Success, the password is setup complete!${RGB_END}"
    echo -en "\n${RGB_INFO}3/5 : Please input a port of server (Default is ${SSPORT}):${RGB_END}"
    read NSSPORT
    [ -z "${NSSPORT}" ] && NSSPORT=${SSPORT}
    echo -e "${RGB_SUCCESS}Success, the port is setup complete!${RGB_END}"
    echo -e "\n${RGB_WARNING}Shadowsocks encryption method list${RGB_END}"
    for ENCRYPTION in ${ENCRYPTIONS[@]} 
    do
    echo -e $ENCRYPTION
    done
    while true
    do
    echo -en "\n${RGB_INFO}4/5 : Please choice the encryption method (Default is aes-256-cfb):${RGB_END}"
    read CENCRYPTION
    [ -z "${CENCRYPTION}" ] && CENCRYPTION="aes-256-cfb"
    if [[ "${ENCRYPTIONS[@]/${CENCRYPTION}/}" == "${ENCRYPTIONS[@]}" ]] ; then
        echo -e "\n${RGB_DANGER}Please choice the encryption method in the list!${RGB_END}"
        continue
    fi
    echo -e "${RGB_SUCCESS}Success, the encryption method has benn complete!${RGB_END}"
    break
    done
cat > /etc/shadowsocks.json <<END
{
    "server":"0.0.0.0",
    "server_port":${NSSPORT},
    "local_address":"127.0.0.1",
    "local_port":1080,
    "password":"${NPASSWORD}",
    "timeout":300,
    "method":"${CENCRYPTION}",
    "fast_open":false
}
END
}

ss_dashboard() {
cat > /etc/init.d/shadowsocks << 'END'
#!/usr/bin/env bash
# chkconfig:    2345 90 10
# Filename:     shadowsocks
# Description:  Shadowsocks dashboard for SpacePack 
# Author:       Vtrois <seaton@vtrois.com>
# Project URL:  https://spacepack.sh
# Github URL:   https://github.com/Vtrois/SpacePack
# License:      GPLv3

help() {
    version
    echo -e "\nUsage: $0 [OPTION]"
    echo -e "\nOption:"
    echo -e "  start                start the shadowsocks server."
    echo -e "  stop                 stop the shadowsocks server."
    echo -e "  restart              restart the shadowsocks server."
    echo -e "  status               detection shadowsocks service status."
    echo -e "  version              show the version info."
    echo -e "  help                 print this help."
    echo -e "\nMail bug reports and suggestions to <seaton@vtrois.com>."
}

version() {
  echo "Shadowsocks server version 1.0"
}

check() {
    PID=$(ps -ef | grep -v grep | grep -i "ssserver" | awk '{print $2}')
    if [ -n "$PID" ]; then
        return 0
    else
        return 1
    fi
}

start() {
    check
    if [ $? -eq 0 ]; then
        echo -e "\033[32m●\033[0m Shadowsocks service has been started"
        exit 0
    else
        ssserver -c /etc/shadowsocks.json -d start > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "Starting shadowsocks:                          [  \033[32mOK\033[0m  ]"
        else
            echo -e "Starting shadowsocks:                          [  \033[31mFAILED\033[0m  ]"
            exit 1
        fi
    fi
}

stop() {
    check
    if [ $? -eq 0 ]; then
        ssserver -c /etc/shadowsocks.json -d stop > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "Stopping shadowsocks:                          [  \033[32mOK\033[0m  ]"
        else
            echo -e "Stopping shadowsocks:                          [  \033[31mFAILED\033[0m  ]"
            exit 1
        fi
    else
        echo -e "\033[37m●\033[0m Shadowsocks service has not been started"
        RETURN=1
    fi
}

status() {
    check
    if [ $? -eq 0 ]; then
        echo -e "\033[32m●\033[0m Shadowsocks service has been started"
        exit 0
    else
        echo -e "\033[37m●\033[0m Shadowsocks service has not been started"
        exit 0
    fi
}

restart() {
    stop
    sleep 1
    start
}

ACTION=$1
[ -z $1 ] && ACTION=start
case "${ACTION}" in
    start|stop|restart|status|version|help)
    $1
    ;;
    *)
    echo -e "Unknown option: $1"
    echo -e "\nUsage: [start] [stop] [restart] [status] [version] [help]"
    exit 1
    ;;
esac
END
chmod +x /etc/init.d/shadowsocks
}

ss_libsodium() {
    if [ ! -f /usr/lib/libsodium.a ]; then
        cd ${BASE}
        tar zxf libsodium-1.0.16.tar.gz >> ${LOCK} 2>&1
        cd libsodium-1.0.16 >> ${LOCK} 2>&1
        ./configure --prefix=/usr >> ${LOCK} 2>&1
        make >> ${LOCK} 2>&1
        make install >> ${LOCK} 2>&1
        if [ $? -ne 0 ]; then
            echo -e "\n${RGB_DANGER}libsodium install failed, please send [${LOCK}] to us!${RGB_END}"
            exit 1
        fi
    fi
    ldconfig >> ${LOCK} 2>&1
    cd ${BASE}
    unzip -q shadowsocks-master.zip >> ${LOCK} 2>&1
    cd ${BASE}/shadowsocks-master >> ${LOCK} 2>&1
    python setup.py install >> ${LOCK} 2>&1
    ss_dashboard
    if [ -f /usr/bin/ssserver ] || [ -f /usr/local/bin/ssserver ]; then
        if [ "${RELEASE}" != "centos" ];then
            update-rc.d -f shadowsocks defaults 90 >> ${LOCK} 2>&1
        else
            chkconfig --add shadowsocks >> ${LOCK} 2>&1
            chkconfig shadowsocks on >> ${LOCK} 2>&1
        fi
            /etc/init.d/shadowsocks start >> ${LOCK} 2>&1
    else
        echo -e "\n${RGB_DANGER}Shadowsocks install failed, please send [${LOCK}] to us!${RGB_END}"
        exit 1
    fi
}

ss_install() {
    echo -e "\n${RGB_INFO}5/5 : Install the libsodium and shadowsocks${RGB_END}"
    echo -en "${RGB_WAIT}Installing (probably for a long time)...${RGB_END}"
    ss_libsodium
    echo -e "\r${RGB_SUCCESS}Success, the shadowsocks installation completion!${RGB_END}"
}

finish_conf() {
    local PUBLICIP=$( public_ip )
    local BASESS=$(echo -n "${CENCRYPTION}:${NPASSWORD}@${PUBLICIP}:${NSSPORT}" | base64 -w0)
    local SHOWSS="ss://${BASESS}"
    echo -e "\n${RGB_WARNING}Shadowsocks Overview (Contains the IP address, Password, Port and Encryption)${RGB_END}"
    echo -e "IP address      : ${PUBLICIP}"
    echo -e "Server Port     : ${NSSPORT}"
    echo -e "Password        : ${NPASSWORD}"
    echo -e "Encryption      : ${CENCRYPTION}"
    echo -e "SS Code         : ${SHOWSS}"
    echo -e "\n${RGB_WARNING}If you use Tencent Cloud or other, please enable port ${NSSPORT} for SecurityGroup!${RGB_END}"
}

clean_all() {
    cd ${BASE}
    rm -rf shadowsocks-master.zip shadowsocks-master libsodium-1.0.16.tar.gz libsodium-1.0.16
}

install() {
    clear
    tool_info
    check_root
    check_lock
    install_module
    ppe_conf
    ss_install
    finish_conf
    clean_all
}

uninstall(){
    clear
    tool_info
    check_root
    echo -en "\n${RGB_DANGER}Ready to uninstall shadowsocks? [y/n]:${RGB_END}"
    while :; do
    read CHOICE
    if [[ ! "${CHOICE}" =~ ^[y,n,Y,N]$ ]]; then
        echo -en "${RGB_DANGER}Please try again [y/n]:${RGB_END}"
    else
        if [ "${CHOICE}" == 'y' ]|| [ "${CHOICE}" == "Y" ]; then
            echo -en "${RGB_WAIT}Uninstalling...${RGB_END}"
            ps -ef | grep -v grep | grep -i "ssserver" > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                /etc/init.d/shadowsocks stop > /dev/null 2>&1
            fi
            if [ "${RELEASE}" != "centos" ];then
                update-rc.d -f shadowsocks remove > /dev/null 2>&1
            else
                chkconfig --del shadowsocks > /dev/null 2>&1
            fi
            rm -f /etc/shadowsocks.json
            rm -f /var/run/shadowsocks.pid
            rm -f /etc/init.d/shadowsocks
            rm -f /var/log/shadowsocks.log
            rm -f ${LOCK}
            echo -e "\r${RGB_SUCCESS}Success, the shadowsocks has been uninstalled!${RGB_END}"
        else
            exit
        fi
        break
    fi
    done
}

ACTION=$1
[ -z $1 ] && ACTION=install
case ${ACTION} in
    install)
        install
        ;;
    -i|--install)
        install
        ;;
    -u|--uninstall)
        uninstall
        ;;
    -v|--version)
        version
        ;;
    -h|--help)
        show_help
        ;;
    *)
        echo -e "Unknown option: $1"
        echo -e "\nUsage: [-i,--install] [-u,--uninstall] [-v,--version] [-h,--help]"
        exit
        ;;
esac