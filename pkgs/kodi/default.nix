{pkgs, ...}: rec {
  pyrollbar = pkgs.kodi-gbm.packages.callPackage ./pyrollbar.nix {};
  hue-service = pkgs.kodi-gbm.packages.callPackage ./hue-service.nix {inherit pyrollbar;};
}