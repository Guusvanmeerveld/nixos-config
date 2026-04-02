{pkgs, ...}: let
  python = pkgs.python314;

  inherit (python.pkgs) callPackage;
in rec {
  fastapi-pagination = callPackage ./fastapi-pagination.nix {};

  python-string-similarity = callPackage ./python-string-similarity.nix {};

  rq-scheduler = callPackage ./rq-scheduler.nix {};

  zipfile-inflate64 = callPackage ./zipfile-inflate64.nix {};

  romm = callPackage ./romm {
    inherit fastapi-pagination python-string-similarity rq-scheduler zipfile-inflate64;
  };
}
