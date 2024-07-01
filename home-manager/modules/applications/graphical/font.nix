{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.font;
in {
  options = {
    custom.applications.graphical.font = {
      default = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            package = lib.mkPackageOption pkgs ["fira-code"] {};

            name = lib.mkOption {
              type = lib.types.str;
              description = "The fonts name";
            };
          };
        });
        default = [
          {
            name = "Fira Code";
            package = pkgs.fira-code;
          }
          {
            name = "Font Awesome 6 Free Solid";
            package = pkgs.font-awesome;
          }
          {
            name = "MesloLGS NF";
            package = pkgs.meslo-lgs-nf;
          }
        ];
      };
    };
  };

  config = {
    home.packages = map (font: font.package) cfg.default;
  };
}
