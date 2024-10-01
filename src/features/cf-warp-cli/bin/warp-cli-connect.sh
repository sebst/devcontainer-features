#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset
        
sudo warp-cli --accept-tos registration new
sudo warp-cli --accept-tos mode warp+doh
sudo warp-cli --accept-tos connect
