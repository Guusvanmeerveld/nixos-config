# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs}: rec {
  # example = pkgs.callPackage ./example { };

  lidarr-plugins = pkgs.callPackage ./lidarr-plugins {};

  pythonPackages = import ./python {inherit pkgs;};

  kodiPackages = import ./kodi {inherit pkgs;};

  firefox = import ./firefox {inherit pkgs;};
  jellyfin = import ./jellyfin {inherit pkgs;};

  export = {
    inherit (pythonPackages) textblob;
    inherit (firefox.themes) blur mono;
    inherit (kodiPackages) hue-service;
  };
}
