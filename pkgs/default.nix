# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs}: rec {
  # example = pkgs.callPackage ./example { };

  lidarr-plugins = pkgs.callPackage ./lidarr-plugins {};
  caddy-with-plugins = pkgs.callPackage ./caddy-with-plugins.nix {};
  free-epic-games = pkgs.callPackage ./free-epic-games.nix {};

  pythonPackages = import ./python {inherit pkgs;};

  kodiPackages = import ./kodi {inherit pkgs;};

  firefox = import ./firefox {inherit pkgs;};
  jellyfin = import ./jellyfin {inherit pkgs;};

  export = {
    inherit free-epic-games lidarr-plugins caddy-with-plugins;
    inherit (jellyfin) intro-skipper trakt listenbrainz dlna lyrics;
    inherit (firefox.themes) blur mono;
    inherit (kodiPackages) hue-service;
  };
}
