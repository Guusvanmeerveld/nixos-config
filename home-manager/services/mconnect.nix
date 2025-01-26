{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.custom.services.mconnect;
in {
  imports = [inputs.mconnect-nix.homeManagerModules.default];

  options = {
    custom.services.mconnect = {
      enable = lib.mkEnableOption "Enable MConnect";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.mconnect = {
      enable = true;

      settings = {
        devices = [
          {
            id = "pixel";
            name = "Pixel 8";
          }
        ];
      };
    };
  };
}
