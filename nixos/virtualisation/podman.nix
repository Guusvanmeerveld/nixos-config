{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.virtualisation.podman;
in {
  options = {
    custom.virtualisation.podman = {
      enable = lib.mkEnableOption "Enable Podman";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;

      dockerCompat = true;
      autoPrune.enable = true;
    };

    environment.systemPackages = with pkgs; [ctop];
  };
}
