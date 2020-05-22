#!/bin/bash

date
rly=/root/go/bin/rly
CHAINID_SELF=dos-ibc-1b
CHAINID_ELSE=gameofzoneshub-1b
CMD1="${rly} tx raw update-client $CHAINID_ELSE $CHAINID_SELF zxihpmutac"
CMD2="${rly} tx raw update-client $CHAINID_SELF $CHAINID_ELSE dqawqufkfp"
IP[0]="http://35.190.35.11:80"
IP[1]="http://35.226.210.13:26657"

run() { 
  echo "----- Before: "
  ${rly} q bal $CHAINID_SELF
  ${rly} q bal $CHAINID_ELSE

  set -x

  local IPCOUNTER=0
  local COUNTER=0
  while true
  do
    local res=$($1)
    local h=$(echo ${res} | jq .height)
    if [[ $h == '"0"' ]] || [[ $h == '' ]]; then
      COUNTER=$(($COUNTER+1))
      sleep 2
      if [[ $COUNTER -lt 10 ]]; then
        echo "^^^^^ Update failure, retrying ${COUNTER} ^^^^^"
        continue
      elif [[ $IPCOUNTER -lt 2 ]]; then
        ${rly} ch edit $CHAINID_ELSE rpc-addr ${IP[$IPCOUNTER]}
        COUNTER=0
        IPCOUNTER=$(($IPCOUNTER+1))
        continue
      else
        echo "~~~~~ re-tried all ips with all times, all failure ~~~~~"
        break
      fi
    else
      echo "%%%%% Update Success! %%%%%"
      break
    fi
  done
  
  set +x

  echo "+++++ After: "
  ${rly} q bal $CHAINID_SELF
  ${rly} q bal $CHAINID_ELSE
}

run "$CMD1"
run "$CMD2"
