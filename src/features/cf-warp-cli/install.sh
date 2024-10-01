#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

echo "=== Installing Cloudflare Warp CLI ==="

./install.checktos.sh

echo "...Installing cli"
DISTRIBUTION="$(. /etc/os-release && echo ${ID:?})"
case "$DISTRIBUTION" in
   "debian") ./install.debian.sh
   ;;
   "ubuntu") ./install.ubuntu.sh
   ;;
   "centos") ./install.centos.sh
   ;;
   "fedora") ./install.fedora.sh
   ;;
   "rhel")   ./install.rhel.sh
   ;;
   *)        ./install.other.sh
   ;;
esac

echo "...Setup connection"
# ./setup.connect.sh
echo "...Installing test script"
./install.testscript.sh

echo "=== Cloudflare Warp CLI installed ==="
