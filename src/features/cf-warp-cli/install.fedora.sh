#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

# echo "Setting up Cloudflare WARP..."
# curl -fsSl https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | sudo tee /etc/yum.repos.d/cloudflare-warp.repo
# sudo yum update -y --setopt=install_weak_deps=False && sudo yum install -y --setopt=install_weak_deps=False cloudflare-warp

echo "Fedora not supported yet:"
echo "libdbus-1.so.3: cannot open shared object file: No such file or directory"

exit 1