{ writeShellApplication, ... }:

writeShellApplication {
  name = "nix-build-to-folder";
  text = ''
    set -euo pipefail

    declare -a nixos=(
      rpi02-installer
      rpi3-installer
      rpi4-installer
      rpi5-installer
    )

    declare -a packages=(
      "libpisp"

      "raspberrypi-utils"
      "raspberrypi-udev-rules"

      # linuxAndFirmware.default.*
      "linux_rpi02"
      "linux_rpi3"
      "linux_rpi4"
      "linux_rpi5"
      "raspberrypifw"
      "raspberrypiWirelessFirmware"
    )

    TARGET="''${1-""}"  # set to "" if not specified

    build_and_copy() {
      local targets=( "$@" )
      local storePath="''${PWD}/result-store/"

      mkdir -p "''${storePath}"

      nix build --no-link "''${targets[@]}"
      nix copy --no-check-sigs --to "file://''${storePath}" "''${targets[@]}"
    }

    set -o xtrace

    if [ -n "''${TARGET}" ]; then
      echo "bulding and copying only the specified target"
      build_and_copy "''${TARGET}"
      exit
    fi

    echo "building and copying all predetermined targets"

    declare -a all_targets=()
    for i in "''${packages[@]}"; do
      all_targets+=( ".#packages.aarch64-linux.$i" )
    done

    for i in "''${nixos[@]}"; do
      all_targets+=( ".#nixosConfigurations.$i.config.system.build.toplevel" )
    done

    build_and_copy "''${all_targets[@]}"

    set +o xtrace
  '';
}