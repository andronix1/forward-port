#!/bin/bash

EXECUTABLE=$0
DESTINATION=$1
SRC_HOST=$2
TARGET_PORT=$3

IP_RE='([0-9]{1,3}\.){3}[0-9]{1,3}'
ADDR_RE='localhost'
PORT_RE='[0-9]{1,5}'

TARGET_PORT_RE="^$PORT_RE$"
SRC_HOST_RE="^(($IP_RE)|($ADDR_RE)):$PORT_RE$"

function usage() {
    echo "$EXECUTABLE <ssh connection string> <source host> <destination port>"
}

function check_input() {
    local name=$1;
    local value=$2;
    local re=$3;
    if ! [[ $value =~ $re ]]; then
        echo "error: invalid $name \`$value\`"
        usage
        exit 1
    fi
}

check_input "host" "$SRC_HOST" "$SRC_HOST_RE"
check_input "target port" "$TARGET_PORT" "$TARGET_PORT_RE"

autossh -M 0 -NC \
	-o ServerAliveCountMax=3 \
	-o ServerAliveInterval=60 \
	-o ExitOnForwardFailure=yes \
	-R localhost:$TARGET_PORT:$SRC_HOST $DESTINATION
