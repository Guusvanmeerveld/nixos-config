# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs}: {
  # example = pkgs.callPackage ./example { };

  clipmon = pkgs.callPackage ./clipmon.nix {};
  mpdris2 = pkgs.callPackage ./mpdris2.nix {};

  pythonPackages = import ./python {inherit pkgs;};

  kodiPackages = import ./kodi {inherit pkgs;};

  firefox = import ./firefox {inherit pkgs;};
}
