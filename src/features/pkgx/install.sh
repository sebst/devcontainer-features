#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

# From `curl -Ssf https://pkgx.sh`
./pkgx-installer.sh

pkgx --integrate && echo "pkgx integrated"
