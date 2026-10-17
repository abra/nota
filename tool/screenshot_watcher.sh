#!/bin/bash
# Host-side companion for integration_test/screenshot_tour_test.dart when it is
# run with `flutter test -d <simulator>`: watches the app's temp dir for
# `<name>.req` markers, captures the simulator screen and answers with
# `<name>.ack`.
#
#   tool/screenshot_watcher.sh <simulator-udid> <output-dir> [timeout-seconds]

set -euo pipefail

udid=${1:?simulator udid}
out=${2:?output dir}
timeout=${3:-900}
# Bundle id from the Xcode project unless overridden.
bundle=${NOTA_BUNDLE_ID:-$(sed -n 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);.*/\1/p' ios/Runner.xcodeproj/project.pbxproj | head -1)}

mkdir -p "$out"
echo "waiting for $bundle on $udid..."
until container=$(xcrun simctl get_app_container "$udid" "$bundle" data 2>/dev/null); do
  sleep 1
done
dir="$container/tmp/nota_shots"
echo "watching $dir"

end=$((SECONDS + timeout))
while [ $SECONDS -lt $end ]; do
  for req in "$dir"/*.req; do
    [ -e "$req" ] || continue
    name=$(basename "$req" .req)
    mv "$req" "$dir/$name.shooting"
    xcrun simctl io "$udid" screenshot "$out/$name.png" >/dev/null 2>&1
    rm -f "$dir/$name.shooting"
    touch "$dir/$name.ack"
    echo "shot $name"
  done
  sleep 0.25
done
