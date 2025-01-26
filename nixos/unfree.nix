{lib, ...}: let
  inherit (builtins) elem;
  inherit (lib) getName;

  unfreePackages = [
    "parsec-bin"
    "unityhub"
    "spotify"
    "apple_cursor"
    "steam"
    "steam-unwrapped"
    "steam-original"
    "steam-run"
    "teamviewer"
  ];
in {
  config.nixpkgs = {
    config = {
      allowUnfreePredicate = p: elem (getName p) unfreePackages;
      allowUnfree = false;
    };
  };
}
