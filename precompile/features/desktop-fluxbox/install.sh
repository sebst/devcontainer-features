#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------


USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"

package_list="
    fluxbox"


set -e

# Clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Determine the appropriate non-root user
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u ${CURRENT_USER} > /dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi
# Add default Fluxbox config files if none are already present
fluxbox_apps="$(cat fluxbox/apps)"

fluxbox_init="$(cat fluxbox/init)"

fluxbox_menu="$(cat fluxbox/menu)"

# Copy config files if the don't already exist
copy_fluxbox_config() {
    local target_dir="$1"
    mkdir -p "${target_dir}/.fluxbox"
    touch "${target_dir}/.Xmodmap"
    if [ ! -e "${target_dir}/.fluxbox/apps" ]; then
        echo "${fluxbox_apps}" > "${target_dir}/.fluxbox/apps"
    fi
    if [ ! -e "${target_dir}/.fluxbox/init" ]; then
        echo "${fluxbox_init}" > "${target_dir}/.fluxbox/init"
    fi
    if [ ! -e "${target_dir}/.fluxbox/menu" ]; then
        echo "${fluxbox_menu}" > "${target_dir}/.fluxbox/menu"
    fi
}

apt_get_update()
{
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

##########################
#  Install starts here   #
##########################

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

apt_get_update

# Install X11, fluxbox and VS Code dependencies
check_packages ${package_list}

# if Ubuntu-24.04, noble(numbat) found, then will install libasound2-dev instead of libasound2.
# this change is temporary, https://packages.ubuntu.com/noble/libasound2 will switch to libasound2 once it is available for Ubuntu-24.04, noble(numbat)
. /etc/os-release
if [ "${ID}" = "ubuntu" ] && [ "${VERSION_CODENAME}" = "noble" ]; then
    echo "Ubuntu 24.04, Noble(Numbat) detected. Installing libasound2-dev package..."
    check_packages "libasound2-dev"
else 
    check_packages "libasound2"
fi

# Install Emoji font if available in distro - Available in Debian 10+, Ubuntu 18.04+
if dpkg-query -W fonts-noto-color-emoji > /dev/null 2>&1 && ! dpkg -s fonts-noto-color-emoji > /dev/null 2>&1; then
    apt-get -y install --no-install-recommends fonts-noto-color-emoji
fi

# Check at least one locale exists
if ! grep -o -E '^\s*en_US.UTF-8\s+UTF-8' /etc/locale.gen > /dev/null; then
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
fi

# Set up fluxbox config
copy_fluxbox_config "/root"
if [ "${USERNAME}" != "root" ]; then
    copy_fluxbox_config "/home/${USERNAME}"
    chown -R ${USERNAME} /home/${USERNAME}/.Xmodmap /home/${USERNAME}/.fluxbox
fi

# Clean up
rm -rf /var/lib/apt/lists/*


# Display the message
cat << EOF


(*) Done!

EOF