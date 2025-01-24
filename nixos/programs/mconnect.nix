{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.custom.programs.mconnect;
in {
  imports = [inputs.mconnect-nix.nixosModules.default];

  options = {
    custom.programs.mconnect = {
      enable = lib.mkEnableOption "Enable MConnect, a KDE connect implementation in Vala";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.mconnect = {
      openFirewall = true;
    };
  };
}
