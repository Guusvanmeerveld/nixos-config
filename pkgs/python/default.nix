{pkgs, ...}: {
  pyjags = pkgs.callPackage ./pyjags.nix {};
  textblob = pkgs.callPackage ./textblob.nix {};
}
