#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

install -v -m 755 ./shoreman.sh /usr/local/bin/shoreman
