#!/bin/bash
 
auto_ssh() {
HOST=$1
USER=$2
PASS=$3


expect -c "
set timeout 10
spawn ssh ${USER}@${HOST}
expect \"Are you sure you want to continue connecting (yes/no)?\" {
    send \"yes\n\"
    expect \"${USER}@${HOST}'s password:\"
    send \"${PASS}\n\"
} \"${USER}@${HOST}'s password:\" {
    send \"${PASS}\n\"
}
interact
"
}