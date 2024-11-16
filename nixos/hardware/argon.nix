{
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.custom.hardware.argon40;
in {
  imports = [
    inputs.argonone-nix.nixosModules.default
  ];

  options = {
    custom.hardware.argon40 = {
      enable = lib.mkEnableOption "Enable Argon RPI case management service";

      eon = {
        enable = lib.mkEnableOption "Enable support for the EON case";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.argon = {
      one = {
        enable = true;

        settings = {
          fanspeed = [
            {
              temperature = 65;
              speed = 40;
            }
            {
              temperature = 75;
              speed = 70;
            }
            {
              temperature = 80;
              speed = 100;
            }
          ];

          ir.enable = true;
        };
      };

      eon.enable = cfg.eon.enable;
    };
  };
}
