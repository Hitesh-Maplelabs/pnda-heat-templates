#!/bin/bash -v

# This script runs on the bastion instance
# It generates the ssh key used to access the rest of
# the instances

set -e

declare -A conf=( )
declare -A specific=( $$SPECIFIC_CONF$$ )

# Override default configuration
for key in "${!specific[@]}"; do conf[$key]="${specific[${key}]}"; done

KEY="$private_key$"
KEYNAME=$keyname$

if [ "x$KEYNAME" != "x" ];
then
HOME_DIR=$(getent passwd $os_user$ | cut -d: -f6)
printf "%b" "$KEY" > ${HOME_DIR}/$KEYNAME.pem
chown $os_user$:$os_user$ ${HOME_DIR}/$KEYNAME.pem
chmod 600 ${HOME_DIR}/$KEYNAME.pem
unset KEY KEYNAME
fi
