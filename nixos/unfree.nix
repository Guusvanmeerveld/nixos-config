{lib, ...}: let
  inherit (builtins) elem;
  inherit (lib) getName;

  unfreePackages = [
    "parsec-bin"
    "unityhub"
    "apple_cursor"
    "steam"
    "steam-unwrapped"
    "teamviewer"
    "intel-ocl"
    "minecraft-server"
  ];
in {
  config.nixpkgs = {
    config = {
      allowUnfreePredicate = p: elem (getName p) unfreePackages;
      allowUnfree = false;
    };
  };
}
