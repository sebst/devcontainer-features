#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset
        
cp bin/warp-cli-connect.sh /usr/local/bin/warp-cli-connect
chmod 755 /usr/local/bin/warp-cli-connect
