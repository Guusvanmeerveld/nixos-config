# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs}: rec {
  # example = pkgs.callPackage ./example { };

  lidarr-plugins = pkgs.callPackage ./lidarr-plugins {};

  cleanuparr = pkgs.callPackage ./cleanuparr {};
  qbittorrent-net-client = pkgs.callPackage ./cleanuparr/qbittorrent {};
  transmission-net-client = pkgs.callPackage ./cleanuparr/transmission {};

  caddy-with-plugins = pkgs.callPackage ./caddy-with-plugins.nix {};
  free-epic-games = pkgs.callPackage ./free-epic-games.nix {};

  pythonPackages = import ./python {inherit pkgs;};

  kodiPackages = import ./kodi {inherit pkgs;};

  firefox = import ./firefox {inherit pkgs;};
  jellyfin = import ./jellyfin {inherit pkgs;};

  export = {
    inherit free-epic-games lidarr-plugins caddy-with-plugins cleanuparr qbittorrent-net-client transmission-net-client;
    inherit (jellyfin) intro-skipper trakt listenbrainz dlna lyrics;
    inherit (firefox.themes) blur mono;
    inherit (kodiPackages) hue-service;
  };
}
