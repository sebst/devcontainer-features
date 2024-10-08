#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset


NOVNC_VERSION="${NOVNCVERSION:-"1.2.0"}"
WEBSOCKETIFY_VERSION=0.10.0

package_list="
    tigervnc-standalone-server \
    tigervnc-common"

package_list_additional="
    tigervnc-tools"

set -e

# Clean up
rm -rf /var/lib/apt/lists/*



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

export DEBIAN_FRONTEND=noninteractive

apt_get_update

# Install X11, fluxbox and VS Code dependencies
check_packages ${package_list}

# On newer versions of Ubuntu (22.04), 
# we need an additional package that isn't provided in earlier versions
if ! type vncpasswd > /dev/null 2>&1; then
    check_packages ${package_list_additional}
fi

# Install noVNC
if [ ! -d "/usr/local/novnc" ]; then
    mkdir -p /usr/local/novnc
    curl -sSL https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.zip -o /tmp/novnc-install.zip
    unzip /tmp/novnc-install.zip -d /usr/local/novnc
    cp /usr/local/novnc/noVNC-${NOVNC_VERSION}/vnc.html /usr/local/novnc/noVNC-${NOVNC_VERSION}/index.html
    curl -sSL https://github.com/novnc/websockify/archive/v${WEBSOCKETIFY_VERSION}.zip -o /tmp/websockify-install.zip
    unzip /tmp/websockify-install.zip -d /usr/local/novnc
    ln -s /usr/local/novnc/websockify-${WEBSOCKETIFY_VERSION} /usr/local/novnc/noVNC-${NOVNC_VERSION}/utils/websockify
    rm -f /tmp/websockify-install.zip /tmp/novnc-install.zip

    # Install noVNC dependencies and use them.
    check_packages python3-minimal python3-numpy
    sed -i -E 's/^python /python3 /' /usr/local/novnc/websockify-${WEBSOCKETIFY_VERSION}/run
fi

install -v -m 755 ./bin/desktop-init.sh /usr/local/share/desktop-init.sh
