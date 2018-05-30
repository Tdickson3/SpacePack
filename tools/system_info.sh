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
# Filename:     system_info.sh
# Description:  System Info tool for SpacePack
# Author:       Vtrois <seaton@vtrois.com>
# Project URL:  https://spacepack.sh
# Github URL:   https://github.com/Vtrois/SpacePack
# License:      GPLv3

RGB_WARNING='💡 \033[33;1m'
RGB_DANGER='\033[31m'
RGB_INFO='\033[36m'
RGB_END='\033[0m'

operation_system() {
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

public_ip() {
    local IP=$( wget -qO- -t1 -T2 api.ip.la )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ip.vtrois.com )
    [ ! -z ${IP} ] && echo ${IP} || echo -e "${RGB_DANGER}Unknown${RGB_END}"
}

MEMTOTAL=$( cat /proc/meminfo | grep MemTotal | awk -F" " '{total=$2/1024}{printf("%d MB",total)}' )
MEMFREE=$( cat /proc/meminfo | grep MemFree | awk -F" " '{free=$2/1024}{printf("%d MB",free)}' )
SWAPTOTAL=$( cat /proc/meminfo  | grep SwapTotal | awk -F" " '{total=$2/1024}{printf("%d MB",total)}' )
SWAPFREE=$( cat /proc/meminfo  | grep SwapFree | awk -F" " '{free=$2/1024}{printf("%d MB",free)}' )
CPUMODEL=$( cat /proc/cpuinfo | grep 'model name' | awk 'END{print}' | awk -F": " '{print $2}' )
CPUMHZ=$( cat /proc/cpuinfo | grep 'cpu MHz' | awk 'END{print}' | awk -F": " '{print($2,"MHz")}' )
CPUCORES=$( cat /proc/cpuinfo | grep 'cpu cores' | awk 'END{print}' | awk -F": " '{print $2}' )
CPUCACHE=$( cat /proc/cpuinfo | grep 'cache size' | awk 'END{print}' | awk -F": " '{print $2}' )
SYSOS=$( operation_system )
SYSRISC=$( uname -m )
SYSLBIT=$( getconf LONG_BIT )
KERNEVERSIONL=$( cat /proc/version | awk -F" " '{print $3}' )
PUBLICIP=$( public_ip )
INTERNALIP=$( ifconfig | grep 'inet' | grep -v '127.0' | xargs | awk -F '[ :]' '{print $2}' )
NAMESERVER=$( cat /etc/resolv.conf | awk '/^nameserver/{print $2}' | awk 'BEGIN{FS="\n";RS="";ORS=""}{for(x=1;x<=NF;x++){print $x"\t"} print "\n"}' )

clear
echo -e "================================================================================="
echo -e "                        System Info tool for SpacePack                           "
echo -e "             For more information please visit https://spacepack.sh              "
echo -e "================================================================================="
echo -e "\n${RGB_WARNING}Hardware Overview (Contains the System, CPU and Memory)${RGB_END}"
echo -e "${RGB_INFO}Operation System       ${RGB_END}: $SYSOS"
echo -e "${RGB_INFO}Hardware Types         ${RGB_END}: $SYSRISC ($SYSLBIT Bit)"
echo -e "${RGB_INFO}Kernel Version         ${RGB_END}: $KERNEVERSIONL"
echo -e "${RGB_INFO}CPU model              ${RGB_END}: $CPUMODEL"
echo -e "${RGB_INFO}CPU Cores              ${RGB_END}: $CPUCORES"
echo -e "${RGB_INFO}CPU Cache Size         ${RGB_END}: $CPUCACHE"
echo -e "${RGB_INFO}CPU Basic Frequency    ${RGB_END}: $CPUMHZ"
echo -e "${RGB_INFO}Total amount of Memory ${RGB_END}: $MEMTOTAL ($MEMFREE Free)"
echo -e "${RGB_INFO}Total amount of Swap   ${RGB_END}: $SWAPTOTAL ($SWAPFREE Free)"
echo -e "\n${RGB_WARNING}Network Overview (Contains the DNS and IP address (public and internal))${RGB_END}"
echo -e "${RGB_INFO}Public IP              ${RGB_END}: $PUBLICIP"
echo -e "${RGB_INFO}Internal IP            ${RGB_END}: $INTERNALIP"
echo -e "${RGB_INFO}Nameserver             ${RGB_END}: $NAMESERVER"