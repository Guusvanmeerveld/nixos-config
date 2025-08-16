{pkgs, ...}: {
  textblob = pkgs.callPackage ./textblob.nix {};
  slskd-api = pkgs.callPackage ./slskd-api.nix {};
}
