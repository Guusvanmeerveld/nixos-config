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
    "teamviewer"
    "nvidia-x11"
    "nvidia-settings"
    "nvidia-persistenced"
    "unifi-controller"
    "mongodb"
    "intel-ocl"
    "vscode-extension-ms-vscode-remote-remote-containers"
  ];
in {
  config.nixpkgs = {
    config = {
      allowUnfreePredicate = p: elem (getName p) unfreePackages;
      allowUnfree = false;
    };
  };
}
