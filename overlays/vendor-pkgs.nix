final: prev: {
  raspberrypi-udev-rules = prev.callPackage ../pkgs/raspberrypi/udev-rules.nix {};

  raspberrypi-utils = prev.callPackage ../pkgs/raspberrypi/raspberrypi-utils.nix {};
}
