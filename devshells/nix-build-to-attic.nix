{ writeShellApplication, jq, attic-client, ... }:

writeShellApplication {
  name = "nix-build-to-attic";
  runtimeInputs = [ jq attic-client ];
  text = ''
    set -euo pipefail

    declare -a nixos=(
      # rpi02-installer
      rpi3-installer
      # rpi4-installer
      rpi5-installer
    )

    declare -a packages=(
      "libpisp"
      
      "raspberrypi-utils"
      "raspberrypi-udev-rules"

      # linuxAndFirmware.default.*
      # "linux_rpi02"
      "linux_rpi3"
      # "linux_rpi4"
      "linux_rpi5"
      "raspberrypifw"
      "raspberrypiWirelessFirmware"
    )

    CACHE="$1"
    TARGET="''${2-""}"  # set to "" if not specified

    build_and_push() {
      local targets=( "$@" )

      nix build "''${targets[@]}" --json \
        | jq -r '.[].outputs | to_entries[].value' \
        | attic push "''${CACHE}" --stdin
    }

    declare -a all_targets=()
    for i in "''${packages[@]}"; do
      all_targets+=( ".#packages.aarch64-linux.$i" )
    done

    for i in "''${nixos[@]}"; do
      all_targets+=( ".#nixosConfigurations.$i.config.system.build.toplevel" )
    done

    set -o xtrace

    if [ -n "''${TARGET}" ]; then
      echo "bulding and pushing only the specified target"
      build_and_push "''${TARGET}"
    else
      echo "building and pushing all predetermined targets"
      build_and_push "''${all_targets[@]}"
    fi

    set +o xtrace
  '';
}
