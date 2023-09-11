#!/bin/bash
set -e
#trap "cleanup $? $LINENO" EXIT

## Deployment Variables
# <UDF name="token_password" label="Your Linode API token" />
# <UDF name="sudo_username" label="The limited sudo user to be created in the cluster" />
# <UDF name="email_address" label="Email Address" example="Example: user@domain.tld" />
# <UDF name="clusterheader" label="Cluster Settings" default="Yes" header="Yes">
# <UDF name="add_ssh_keys" label="Add Account SSH Keys to All Nodes?" oneof="yes,no"  default="yes" />
# <UDF name="cluster_size" label="Total instance count" default="6" oneof="6" />
# <UDF name="servers" label="Nomad Server count" default="3" oneOf="3" />
# <UDF name="clients" label="Nomad client size" default="3" oneof="3" />

# git repo
git_username="n0vabyte"
export GIT_PAT=""
export GIT_REPO_1="https://$git_username:${GIT_PAT}@github.com/$git_username/nomad-occ_share.git"
export GIT_REPO_2="https://$git_username:${GIT_PAT}@github.com/$git_username/nomad-client-occ_share.git"
export DEBIAN_FRONTEND=non-interactive
export UUID=$(uuidgen | awk -F - '{print $1}')
export CLUSTER_MODE='cluster'

# enable logging
exec > >(tee /dev/ttyS0 /var/log/stackscript.log) 2>&1
# source script libraries
source <ssinclude StackScriptID=1>

function cleanup {
  if [ "$?" != "0" ] || [ "$SUCCESS" == "true" ]; then
    #deactivate
#    cd ${HOME}
#    if [ -d "/tmp/linode" ]; then
#      rm -rf /tmp/linode
#    fi
#    if [ -d "/usr/local/bin/run" ]; then
#      rm /usr/local/bin/run
#    fi
#    stackscript_cleanup
  echo "fake delete.."
  fi
}
function add_privateip {
  echo "[info] Adding instance private IP"
  curl -H "Content-Type: application/json" \
      -H "Authorization: Bearer ${TOKEN_PASSWORD}" \
      -X POST -d '{
        "type": "ipv4",
        "public": false
      }' \
      https://api.linode.com/v4/linode/instances/${LINODE_ID}/ips
}
function get_privateip {
  curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${TOKEN_PASSWORD}" \
   https://api.linode.com/v4/linode/instances/${LINODE_ID}/ips | \
   jq -r '.ipv4.private[].address'
}
function configure_privateip {
  LINODE_IP=$(get_privateip)
  if [ ! -z "${LINODE_IP}" ]; then
          echo "[info] Linode private IP present"
  else
          echo "[warn] No private IP found. Adding.."
          add_privateip
          LINODE_IP=$(get_privateip)
          ip addr add ${LINODE_IP}/17 dev eth0 label eth0:1
  fi
}
function rename_provisioner {
  INSTANCE_PREFIX=$(curl -sH "Authorization: Bearer ${TOKEN_PASSWORD}" "https://api.linode.com/v4/linode/instances/${LINODE_ID}" | jq -r .label)
  export INSTANCE_PREFIX="${INSTANCE_PREFIX}"
  echo "[info] renaming the provisioner"
  curl -s -H "Content-Type: application/json" \
      -H "Authorization: Bearer ${TOKEN_PASSWORD}" \
      -X PUT -d "{
        \"label\": \"${INSTANCE_PREFIX}-server-1-${UUID}\"
      }" \
      https://api.linode.com/v4/linode/instances/${LINODE_ID}
}
function tag_provisioner {
  export INSTANCE_TAG='consul-server'
  echo "[info] tagging the provisioner"
  curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${TOKEN_PASSWORD}" -X PUT \
    -d "{\"tags\": [\"${INSTANCE_TAG}\"]}" \
    https://api.linode.com/v4/linode/instances/${LINODE_ID}   
}

function setup {
  # install dependencies
  export DEBIAN_FRONTEND=non-interactive
  apt-get update && apt-get upgrade -y
  apt-get install -y jq git python3 python3-pip python3-dev build-essential firewalld
  # add private IP address
  rename_provisioner
  tag_provisioner
  configure_privateip  
  # write authorized_keys file
  if [ "${ADD_SSH_KEYS}" == "yes" ]; then
    curl -sH "Content-Type: application/json" -H "Authorization: Bearer ${TOKEN_PASSWORD}" https://api.linode.com/v4/profile/sshkeys | jq -r .data[].ssh_key > /root/.ssh/authorized_keys
  fi
  # clone repo and set up ansible environment
  git clone ${GIT_REPO_1} /tmp/linode
  git clone ${GIT_REPO_2} /tmp/linode/nomad-client-occ_share
  # clone one branch to test 
  # git clone -b develop ${GIT_REPO_1} /tmp/linode
  cd /tmp/linode
  pip3 install virtualenv
  python3 -m virtualenv env
  source env/bin/activate
  pip install pip --upgrade
  pip install -r requirements.txt
  ansible-galaxy install -r collections.yml
  # copy run script to path
  cp scripts/run.sh /usr/local/bin/run
  chmod +x /usr/local/bin/run
}
# main
setup
run ansible:build
run ansible:deploy && export SUCCESS="true" 