# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs}: rec {
  # example = pkgs.callPackage ./example { };

  mpdris2 = pkgs.callPackage ./mpdris2.nix {};
  radb = pkgs.callPackage ./radb.nix {};
  nwg-dock = pkgs.callPackage ./nwg-dock.nix {};
  dnsmasqstats = pkgs.callPackage ./dnsmasqstats.nix {};
  ryubing = pkgs.callPackage ./ryubing {};

  nx_tzdb = pkgs.callPackage ./sudachi/nx_tzdb.nix {};
  sudachi = pkgs.callPackage ./sudachi (pkgs.kdePackages // {inherit nx_tzdb;});

  pythonPackages = import ./python {inherit pkgs;};

  soularr = pkgs.callPackage ./soularr.nix {
    inherit (pythonPackages) slskd-api;
  };

  kodiPackages = import ./kodi {inherit pkgs;};

  firefox = import ./firefox {inherit pkgs;};
  jellyfin = import ./jellyfin {inherit pkgs;};

  export = {
    inherit mpdris2 radb dnsmasqstats ryubing soularr;
    inherit (pythonPackages) textblob;
    inherit (firefox.themes) blur mono;
    inherit (kodiPackages) hue-service;
  };
}
