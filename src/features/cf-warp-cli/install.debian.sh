#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset
        
# echo "Setting up Cloudflare WARP..."
# curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
# echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
# sudo apt-get update && sudo apt-get install -y --no-install-recommends cloudflare-warp

echo "Debian is not supported due to a key error in the Cloudflare WARP repository. Please install manually."
exit 1
