#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

# Set the base directory
FEATURES_DIR="./src/features"

# Check if the features directory exists
if [ -d "$FEATURES_DIR" ]; then
  # Loop over each directory in the features directory
  for DIR in "$FEATURES_DIR"/*/; do
    # Remove the trailing slash to get the directory name
    DIRNAME=$(basename "$DIR")
    
    # Call the build script with the directory name
    ./build_feature.sh "$DIRNAME"
  done
else
  echo "Directory $FEATURES_DIR does not exist."
  exit 1
fi
