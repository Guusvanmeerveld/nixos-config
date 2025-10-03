{pkgs, ...}: {
  textblob = pkgs.callPackage ./textblob.nix {};
}
