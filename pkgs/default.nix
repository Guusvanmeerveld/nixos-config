# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs}: rec {
  # example = pkgs.callPackage ./example { };

  clipmon = pkgs.callPackage ./clipmon.nix {};
  mpdris2 = pkgs.callPackage ./mpdris2.nix {};
  radb = pkgs.callPackage ./radb.nix {};
  nwg-dock = pkgs.callPackage ./nwg-dock.nix {};
  dnsmasqstats = pkgs.callPackage ./dnsmasqstats.nix {};
  ryubing = pkgs.callPackage ./ryubing {};
  nx_tzdb = pkgs.callPackage ./sudachi/nx_tzdb.nix {};
  sudachi = pkgs.callPackage ./sudachi (pkgs.kdePackages // {inherit nx_tzdb;});

  pythonPackages = import ./python {inherit pkgs;};

  kodiPackages = import ./kodi {inherit pkgs;};

  firefox = import ./firefox {inherit pkgs;};

  ciBuildable = {
    inherit clipmon mpdris2 radb dnsmasqstats ryubing;
    inherit (pythonPackages) pyjags textblob;
    inherit (firefox.themes) blur mono;
    inherit (kodiPackages) hue-service;
  };
}
