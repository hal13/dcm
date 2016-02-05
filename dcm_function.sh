#!/bin/bash

#関数定義
##エラー処理
function err() {
  if [ $# -eq 1 ] ; then
      echo "ERROR : "${1}
  else
      echo "ERROR : unknown error"
  fi
}

##マシン名生成
function create_name() {
  
  local name_bef="kvm_centos7_"
  local name_aft="`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1 | sort | uniq`"
  
  echo "${name_bef}${name_aft}"
}

##ファイルコピー(Scp)
function copy_file()
{
  #変数定義
  local HOST=$1
  local USER=$2
  local PASS=$3
  local TARGET_FILE=$4
  local TARGET_DIR=$5
  
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
  
}

##ファイルの削除(Remove)
function remove_file()
{
  #変数定義
  local HOST=$1
  local USER=$2
  local PASS=$3
  local TARGET_FILE=$4

  auto_ssh ${HOST} ${USER} ${PASS} rm -rf ${TARGET_FILE}
  
  if [ $? -eq 0 ]; then
    return 0
  else
    return 1
  fi
  
}

##仮想マシンの生成・立ち上げ(virt-install)
function create_vm()
{
  #変数定義
  local NAME=`create_name`
  local DISK_PATH="/var/kvm/disk/kvm_centos7/disk.qcow2,format=qcow2,size=8"
  local NETWORK_BRIDGE="virtbr0"
  local ARCH="x86_64"
  local OS_TYPE="linux"
  if [ ${1} -eq 0 ]; then
    VCPUS="2"
  else
    VCPUS=$1
  fi
  
  if [ ${2} -eq 0 ]; then
    RAM="1024"
  else
    RAM=$2
  fi

  virt-install \ << EOF
  #auto_ssh ${HOST} ${USER} ${PASS} virt-install \
    --name=${NAME} \
    --vcpus=${VCPUS} \
    --ram=${RAM} \
    --disk path=${DISK_PATH} \
    --network bridge=${NETWORK_BRIDGE} \
    --arch=${ARCH} \
    --os-type=${OS_TYPE} \
    --noautoconsole
    EOF
  
  if [ $? -eq 0 ]; then
    echo ${NAME}
  else
    return 1
  fi
  
}

##仮想マシンの削除(virsh undefine)
function delete_vm() {
  vm_code=$1
  
  virsh undefine ${vm_code}
  
  if [ $? -eq 0 ]; then
    echo "SUCCESS"
  else
    return 1
  fi
}

##仮想マシンのスタート(virsh start)
function start_vm() {
  vm_code=$1

  virsh start ${vm_code}

  if [ $? -eq 0 ]; then
    echo "SUCCESS"
  else
    return 1
  fi
}

##仮想マシンの停止(virsh destroy)
function destroy_vm() {
  vm_code=$1

  virsh destroy ${vm_code}

  if [ $? -eq 0 ]; then
    echo "SUCCESS"
  else
    return 1
  fi
}

##付与可能IPアドレス検索
function getIP_addr() {
  management_file=$1
  
  ret=`cat ${management_file} | grep -v '#' | head -1`
  
  if [ $? -eq 0 ]; then
    echo ${ret}
  else
    return 1
  fi
  
}