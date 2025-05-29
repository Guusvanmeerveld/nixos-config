{lib, ...}: let
  inherit (builtins) elem;
  inherit (lib) getName;

  unfreePackages = [
    "parsec-bin"
    "unityhub"
    "spotify"
    "tidal-hifi"
    "castlabs-electron"
    "apple_cursor"
    "steam"
    "steam-unwrapped"
    "steam-original"
    "steam-run"
    "teamviewer"
    "nvidia-x11"
    "nvidia-settings"
    "nvidia-persistenced"
  ];
in {
  config.nixpkgs = {
    config = {
      allowUnfreePredicate = p: elem (getName p) unfreePackages;
      allowUnfree = false;
    };
  };
}
