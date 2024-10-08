#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/desktop-lite.md
# Maintainer: The VS Code and Codespaces Teams


package_list="
    dbus-x11 \
    x11-utils \
    x11-xserver-utils \
    xdg-utils \
    fbautostart \
    at-spi2-core \
    xterm \
    eterm \
    nautilus\
    mousepad \
    seahorse \
    gnome-icon-theme \
    gnome-keyring \
    libx11-dev \
    libxkbfile-dev \
    libsecret-1-dev \
    libgbm-dev \
    libnotify4 \
    libnss3 \
    libxss1 \
    xfonts-base \
    xfonts-terminus \
    fonts-noto \
    fonts-wqy-microhei \
    fonts-droid-fallback \
    htop \
    ncdu \
    curl \
    ca-certificates\
    unzip \
    nano \
    locales"

set -e

# Clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi


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

# Install the Cascadia Code fonts - https://github.com/microsoft/cascadia-code
if [ ! -d "/usr/share/fonts/truetype/cascadia" ]; then
    curl -sSL https://github.com/microsoft/cascadia-code/releases/download/v2008.25/CascadiaCode-2008.25.zip -o /tmp/cascadia-fonts.zip
    unzip /tmp/cascadia-fonts.zip -d /tmp/cascadia-fonts
    mkdir -p /usr/share/fonts/truetype/cascadia
    mv /tmp/cascadia-fonts/ttf/* /usr/share/fonts/truetype/cascadia/
    rm -rf /tmp/cascadia-fonts.zip /tmp/cascadia-fonts
fi


# Set up folders for scripts and init files
mkdir -p /var/run/dbus /usr/local/etc/vscode-dev-containers/

# Script to change resolution of desktop
install -v -m 755 ./bin/set-resolution.sh /usr/local/bin/set-resolution

# Clean up
rm -rf /var/lib/apt/lists/*



# Display the message
cat << EOF


(*) Done!

EOF