# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs}: {
  # example = pkgs.callPackage ./example { };
  pyjags = pkgs.callPackage ./pyjags.nix {};
  textblob = pkgs.callPackage ./textblob.nix {};

  clipmon = pkgs.callPackage ./clipmon.nix {};

  hue-service = pkgs.kodiPackages.callPackage ./hue-service.nix {};
}
