#!/bin/bash

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


#関数定義
##エラー処理
function die() {
  if [ $# -eq 1 ] ; then
      echo "ERROR : ${1}"
  else
      echo "ERROR : unknown error"
  fi
  exit 1
}

##マシン名生成
function create_name() {
  
  name_bef="kvm_centos7_"
  name_aft="`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1 | sort | uniq`"
  
  echo "${name_bef}${name_aft}"
}

##ファイルコピー(Scp)
function copy_file()
{
  #変数定義
  HOST=$1
  USER=$2
  PASS=$3
  TARGET_FILE=$4
  TARGET_DIR=$5
  
  expect -c "
  spawn scp ${TARGET_FILE} ${USER}@${HOST}:${TARGET_DIR}
  expect {
  \"Are you sure you want to continue connecting (yes/no)? \" {
  send \"yes\r\"
  expect \"password:\"
  send \"${PASS}\r\"
  } \"password:\" {
  send \"${PASS}\r\"
  }
  }
  interact
  "
  
  if [ $? -eq 0 ]; then
    return 0
  else
    die $?
  fi
  
}

##ファイルの削除(Remove)
function remove_file()
{
  #変数定義
  HOST=$1
  USER=$2
  PASS=$3
  TARGET_FILE=$4

  ssh root@${1} -o "StrictHostKeyChecking=no" rm -rf ${2}
  
  if [ $? -eq 0 ]; then
    return 0
  else
    die $?
  fi
  
}

##仮想マシンの生成・立ち上げ(virt-install)
function create_vm()
{
  #変数定義
  NAME=`create_name`
  VCPUS="2"
  RAM="1024"
  DISK_PATH="path=/var/kvm/disk/${NAME}/disk.qcow2,format=qcow2,size=8"
  NETWORK_BRIDGE="virtbr0"
  ARCH="x86_64"
  OS_TYPE="linux"
  ISO_FILE=$4
  HOST=$1
  USER=$2
  PASS=$3

  ssh ${USER}@${HOST} -o "StrictHostKeyChecking=no" virt-install \
    --name=${NAME} \
    --vcpus=${VCPUS} \
    --ram=${RAM} \
    --disk path=${DISK_PATH} \
    --network bridge=${NETWORK_BRIDGE} \
    --arch=${ARCH} \
    --os-type=${OS_TYPE} \
    --cdrom=${ISO_FILE}
  
  if [ $? -eq 0 ]; then
    echo ${NAME}
  else
    die $?
  fi
  
}

##仮想マシンの削除(virsh undefine)
function delete_vm() {
  vm_code=$1
  
  virsh undefine ${vm_code}
  
  if [ $? -eq 0 ]; then
    echo "SUCCESS"
  else
    die $?
  fi
}

##仮想マシンのスタート(virsh start)
function start_vm() {
  vm_code=$1

  virsh start ${vm_code}

  if [ $? -eq 0 ]; then
    echo "SUCCESS"
  else
    die $?
  fi
}

##仮想マシンの停止(virsh destroy)
function destroy_vm() {
  vm_code=$1

  virsh destroy ${vm_code}

  if [ $? -eq 0 ]; then
    echo "SUCCESS"
  else
    die $?
  fi
}

