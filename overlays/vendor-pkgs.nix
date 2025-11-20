self: super: { # final: prev:
  raspberrypi-udev-rules = super.callPackage ../pkgs/raspberrypi/udev-rules.nix {};

  raspberrypi-utils = super.callPackage ../pkgs/raspberrypi/raspberrypi-utils.nix {};
}
