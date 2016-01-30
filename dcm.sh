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
TARGET_FILE="/var/kvm/iso/CentOS-x86_64-Minimal-1503-01.iso"
TARGET_DIR="/etc/libvirt/qemu/"

#引数のチェック
  if [ $# -gt 2 ]; then
    echo "argument err"
    exit 1
  fi

#メイン処理
  case $COMMAND in
    "create")
      ret=""
      for ((i=1; i>3; i++));do
        copy_file 
        $ret=`auto_ssh ${host${i}} ${USER} ${PASS} create_vm`
        if [ $? -eq 0 ];then
          
      done
          
    "undefine")
    "start")
    "destroy")
    *)
      echo "COMMAND ERROR"
      exit 1
  esac
