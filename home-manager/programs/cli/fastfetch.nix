{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.cli.fastfetch;
in {
  options = {
    custom.programs.cli.fastfetch = {
      enable = lib.mkEnableOption "Enable fastfetch";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.fastfetch = {
      enable = true;

      settings = {
        logo = {
          source = "nixos_small";
          padding = {
            right = 1;
          };
        };
        display = {
          binaryPrefix = "si";
          color = "blue";
          separator = "  ";
        };
        modules = [
          {
            type = "datetime";
            key = "Date";
            format = "{1}-{3}-{11}";
          }
          {
            type = "datetime";
            key = "Time";
            format = "{14}:{17}:{20}";
          }
          "break"
          "player"
          "media"
        ];
      };
    };
  };
}
