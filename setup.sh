#!/bin/bash

set -e

EXECUTABLE=$0
INSTALL_DIR="/opt/forward-port"

function check_root() {
    if [[ "$UID" -ne "0" ]]; then
        echo "Installer should be runned as root"
        exit 1
    fi
}

function uninstall() {
    rm -Rf $INSTALL_DIR
}

function install() {
    if ! [ -x "$(command -v autossh)" ]; then
      echo "Error: autossh is not installed"
      exit 1
    fi
    mkdir -p $INSTALL_DIR
    cp forward-port.sh $INSTALL_DIR
    chmod +x $INSTALL_DIR/forward-port.sh
    echo "Installed to: $INSTALL_DIR/forward-port.sh"
}

function add_service() {
    local name=$1;
    local ssh_conn_str=$2;
    local source_addr=$3;
    local target_port=$4;

    local file_path="/etc/systemd/system/$name.service";

    cp template.service "$file_path"
    sed -i -e "s/<CONN_DATA>/$ssh_conn_str $source_addr $target_port/g" "$file_path"
    sed -i -e "s/<NAME>/$source_addr -> $target_port/g" "$file_path"

    echo "Service added to: $file_path"
}

function answer() {
    local text=$1;

    read -p "$text? (y/N): " CONFIRM && \
        [[ $CONFIRM == [yY] ]] || \
        exit 1
}

function add_service_form() {
    echo "Adding service..."
    read -p "Enter service name: " SERVICE_NAME
    read -p "Enter SSH connection string: " SSH_CONN_STR
    read -p "Enter address to forward: " SOURCE_ADDR
    read -p "Enter target port: " TARGET_PORT

    add_service $SERVICE_NAME $SSH_CONN_STR $SOURCE_ADDR $TARGET_PORT

    answer "Run and enable service"
    systemctl enable $SERVICE_NAME
    systemctl start $SERVICE_NAME
}

function remove_service_form() {
    read -p "Enter service name: " SERVICE_NAME
    systemctl stop $SERVICE_NAME
    systemctl disable $SERVICE_NAME

    rm "/etc/systemd/system/$SERVICE_NAME.service";
}

function usage() {
    echo "$EXECUTABLE [uninstall | install | add | remove | help]"
}

check_root

if ! [ -e $INSTALL_DIR ]; then
    echo "forward-port.sh script is not installed"
    answer "Install"
    install
    exit 0
fi

case "$1" in
    "install") install ;;
    "uninstall") uninstall ;;
    "add") add_service_form ;;
    "remove") remove_service_form ;;
    "help") usage ;;
    "") usage ;;
    *)
        echo "Invalid command \`$1\`"
        usage
        ;;
esac
