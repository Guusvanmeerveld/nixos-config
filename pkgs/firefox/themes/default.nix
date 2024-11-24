{pkgs, ...}: {
  mono = pkgs.callPackage ./mono.nix {};
  blur = pkgs.callPackage ./blur.nix {};
}
