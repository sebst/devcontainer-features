#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

readonly makeSelfDownloadUrl='https://github.com/megastep/makeself/releases/download/release-2.5.0/makeself-2.5.0.run'
curl -fsSL --retry 3 "${makeSelfDownloadUrl}" -o makeself.run
chmod +x makeself.run
./makeself.run 
readonly makeselfPath=$(find . -name makeself.sh)

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly srcDir="${SCRIPT_DIR}/src/features"
readonly featureName=$1
readonly featureSrcDir="${srcDir}/${featureName}"
readonly featureTargetDir="${SCRIPT_DIR}/features/${featureName}"

if [ ! -d "${featureSrcDir}" ]; then
  echo "=== [ERROR] Feature source directory not found: ${featureSrcDir}"
  exit 1
fi

# Create a temporary directory to build the feature
readonly tmpDir=$(mktemp -d -t "${featureName}.XXXXXXXXXX")
trap 'rm -rf "${tmpDir}"' EXIT

# Copy the feature source to the temporary directory
cp -r "${featureSrcDir}" "${tmpDir}"

# Remove `devcontainer-feature.json` from the temporary directory
rm -f "${tmpDir}/${featureName}/devcontainer-feature.json"

# Add the entrypoint script to the temporary directory
echo '#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset' > "${tmpDir}/entrypoint.sh"
echo '' >> "${tmpDir}/entrypoint.sh"
echo "echo '==== DEVCONTAINER.COM ===='" >> "${tmpDir}/entrypoint.sh"
echo "echo '=== Feature: ${featureName}'" >> "${tmpDir}/entrypoint.sh"
echo "echo '=========================='" >> "${tmpDir}/entrypoint.sh"
echo "cd \"${featureName}\"" >> "${tmpDir}/entrypoint.sh"
echo './install.sh' >> "${tmpDir}/entrypoint.sh"
chmod +x "${tmpDir}/entrypoint.sh"

# Create the feature archive
rm -rf ${featureTargetDir}
mkdir -p ${featureTargetDir}
${makeselfPath} --gzip --current --nox11 --sha256 "${tmpDir}/" "${featureTargetDir}/install.sh" "Devcontainer.com Feature: ${featureName}" "./entrypoint.sh"

# Copy the `devcontainer-feature.json` to the feature directory
cp "${featureSrcDir}/devcontainer-feature.json" "${featureTargetDir}/devcontainer-feature.json"
