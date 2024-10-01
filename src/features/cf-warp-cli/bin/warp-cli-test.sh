#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

echo "Checking WARP connection..."
curl -s https://1.1.1.1/cdn-cgi/trace | grep "warp=on"
echo "Done."
