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
# Filename:     ssh_port.sh
# Description:  Revise SSH port tool for SpacePack
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

tool_info() {
    echo -e "================================================================================="
    echo -e "                       Revise SSH port tool for SpacePack                        "
    echo -e "             For more information please visit https://spacepack.sh              "
    echo -e "================================================================================="
}

check_root(){
    if [[ $EUID -ne 0 ]]; then
       echo -e "${RGB_DANGER}The script must be run as root!${RGB_END}"
       exit 1
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
}

ssh_port() {
    local PORT=$( cat /etc/ssh/sshd_config | grep ^Port | awk '{print $2}' )
    [ ! -z ${PORT} ] && echo ${PORT} || echo 22
}

clear
tool_info
check_root
if [ -e "/etc/ssh/sshd_config" ]; then
    SSHPORT=$( ssh_port )
    echo -en "\n${RGB_INFO}1/2 : Please enter SSH port (Range of 1024 to 65535, current is ${SSHPORT}):${RGB_END}"
    while :; do
    read NPORT
    NPTSTATUS=$( netstat -lnp|grep ${NPORT} )
    if [ -n "${NPTSTATUS}" ];then
        echo -en "${RGB_DANGER}The port is already occupied, Please try again (Range of 1024 to 65535):${RGB_END}"
    elif [ "${NPORT}" -lt 1024 ] || [ "${NPORT}" -gt 65535 ];then
        echo -en "${RGB_DANGER}Please try again (Range of 1024 to 65535):${RGB_END}"
    else
        break
    fi
    done
    echo -en "${RGB_WAIT}Checking...${RGB_END}"
    if [ "${SSHPORT}" -ne "22" ]; then
        sed -i "s@^Port.*@Port ${NPORT}@" /etc/ssh/sshd_config
    else
        sed -i "s@^#Port.*@&\nPort ${NPORT}@" /etc/ssh/sshd_config
    fi
    echo -e "\r${RGB_SUCCESS}Success, the SSH port modification completed!${RGB_END}\n"
    echo -e "${RGB_INFO}2/2 : Restart the service to take effect${RGB_END}"
    echo -en "${RGB_WAIT}Checking...${RGB_END}"
    check_os
    if [ "${RELEASE}" != "centos" ];then
        /etc/init.d/ssh restart > /dev/null 2>&1
    else
        CENTOSVERSION=$( rpm -q centos-release | cut -d- -f3 )
        if [ "${CENTOSVERSION}" == "7" ];then
            systemctl restart sshd > /dev/null 2>&1
        else
            service sshd restart > /dev/null 2>&1
        fi
    fi
    echo -e "\r${RGB_SUCCESS}Success, the SSH service restart completed!${RGB_END}\n"
    echo -e "${RGB_WARNING}Please enable port ${NPORT} for firewalld/iptables manually set if necessary!${RGB_END}\n"
    echo -e "${RGB_WARNING}If you use Tencent Cloud or other, please enable port ${NPORT} for SecurityGroup!${RGB_END}"
else
    echo -e "${RGB_DANGER}Can not find the sshd server system-wide configuration file!${RGB_END}"
    exit 1
fi