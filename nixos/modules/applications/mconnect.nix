{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.custom.applications.mconnect;
in {
  imports = [inputs.mconnect-nix.nixosModules.default];

  options = {
    custom.applications.mconnect = {
      enable = lib.mkEnableOption "Enable MConnect";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.mconnect = {
      openFirewall = true;
    };
  };
}
