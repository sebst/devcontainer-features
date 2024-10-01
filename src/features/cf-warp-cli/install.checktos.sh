#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset
        
if [ "${ACCEPT_TOS}" != 'YES' ]; then
    echo "You must accept the Cloudflare WARP terms of service by setting the 'accept_tos' option to 'YES'."
    exit 1
fi
