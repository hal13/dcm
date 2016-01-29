#!/bin/bash

. dcm_auto_ssh.sh
. dcm_function.sh

COMMAND=$1
vm_code=$2

#定数定義
host1="192.168.56.103"
host2="192.168.56.104"
host3="192.168.56.105"

USER="root"
PASS="cloud"
TARGET_FILE="hoge.xml"
TARGET_DIR="/etc/libvirt/qemu/"

#引数のチェック
  if [ $# -gt 2 ]; then
    echo "argument err"
    exit 1
  fi

#メイン処理
  case $COMMAND in
    "create")
    "undefine")
    "start")
    "destroy")
  esac
