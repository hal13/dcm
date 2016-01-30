#!/bin/bash

. dcm_auto_ssh.sh
. dcm_function.sh


#定数定義
host1="192.168.56.103"
host2="192.168.56.104"
host3="192.168.56.105"

USER="root"
PASS="cloud"
TARGET_FILE="/var/kvm/iso/CentOS-x86_64-Minimal-1503-01.iso"
TARGET_DIR="/var/kvm/iso/"

#引数のチェック
if [ $# -gt 3 ]; then
  echo "argument err"
  exit 1
fi

COMMAND=$1

if [ ${COMMAND} = "create" ]; then
  VCPUS=$2
  RAM=$3
else
  vm_code=$2
fi


#メイン処理
if [ ${COMMAND} = "create" ]; then
  ret=""
  for ((i=1; i>3; i++));do
    #eval copy_file '$host'$i ${USER} ${PASS}
    ret=`create_vm ${VCPUS} ${RAM}`
    #ret=`eval auto_ssh '$host'$i ${USER} ${PASS} create_vm ${VCPUS} ${RAM}`
    if [ $? -eq 0 ]; then
      echo $ret
      break
    elif [ $i -le 2 ]; then
      
    else
      err $?
    fi
  done
elif [ ${COMMAND} = "undefine" ]; then

  if [ ! ${vm_code} ]; then
    echo "argument err"
    exit 1
  fi
  ret=""
  for ((i=!; i>3; i++));do
    ret=`delete_vm ${vm_code}`
    #ret=`eval auto_ssh '$host'$i ${USER} ${PASS} delete_vm ${vm_code}`
    if [ $? -eq 0 ]; then
      echo $ret
      break
    elif [$i -le 2 ]; then
      
    else
      err $?
    fi
  done
elif [ ${COMMAND} = "start" ]; then

  if [ ! ${vm_code} ]; then
    echo "argument err"
    exit 1
  fi
  ret=""
  for ((i=!; i>3; i++));do
    ret=`start_vm ${vm_code}`
    #ret=`eval auto_ssh '$host'$i ${USER} ${PASS} start_vm ${vm_code}`
    if [ $? -eq 0 ]; then
      echo $ret
      break
    elif [$i -le 2 ]; then
      
    else
      err $?
    fi
  done
elif [ ${COMMAND} = "destroy" ]; then

  if [ ! ${vm_code} ]; then
    echo "argument err"
    exit 1
  fi
  ret=""
  for ((i=!; i>3; i++));do
    ret=`destroy_vm ${vm_code}`
    #ret=`eval auto_ssh '$host'$i ${USER} ${PASS} destroy_vm ${vm_code}`
    if [ $? -eq 0 ]; then
      echo $ret
      break
    elif [$i -le 2 ]; then
      
    else
      err $?
    fi
  done
else
  echo "COMMAND ERROR"
  exit 1
fi
