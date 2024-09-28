# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs}: rec {
  # example = pkgs.callPackage ./example { };
  pyjags = pkgs.callPackage ./pyjags.nix {};
  textblob = pkgs.callPackage ./textblob.nix {};

  clipmon = pkgs.callPackage ./clipmon.nix {};

  pyrollbar = pkgs.kodi-gbm.packages.callPackage ./pyrollbar.nix {};
  hue-service = pkgs.kodi-gbm.packages.callPackage ./hue-service.nix {inherit pyrollbar;};
}
