# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{
  pkgs,
  bun2nix,
}: rec {
  seerr = pkgs.callPackage ./seerr.nix {};

  samsung-jellyfin-installer = pkgs.callPackage ./samsung-jellyfin-installer {};

  cleanuparr = pkgs.callPackage ./cleanuparr {};
  qbittorrent-net-client = pkgs.callPackage ./cleanuparr/qbittorrent {};
  transmission-net-client = pkgs.callPackage ./cleanuparr/transmission {};

  caddy-with-plugins = pkgs.callPackage ./caddy-with-plugins.nix {};
  free-epic-games = pkgs.callPackage ./free-epic-games.nix {};
  degoog = pkgs.callPackage ./degoog.nix {inherit bun2nix;};

  pythonPackages = import ./python {inherit pkgs;};

  dockerPackages = import ./docker {inherit pkgs;};

  kodiPackages = import ./kodi {inherit pkgs;};

  firefox = import ./firefox {inherit pkgs;};
  jellyfin = import ./jellyfin {inherit pkgs;};

  export = {
    inherit free-epic-games caddy-with-plugins cleanuparr qbittorrent-net-client transmission-net-client samsung-jellyfin-installer;
    inherit (jellyfin) intro-skipper trakt listenbrainz dlna lyrics;
    inherit (pythonPackages) romm;
    inherit (firefox.themes) blur mono;
    inherit (kodiPackages) hue-service;

    # romm-docker = dockerPackages.romm;
  };
}
