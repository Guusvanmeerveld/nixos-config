{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.theming.font;
in {
  options = {
    custom.applications.graphical.theming.font = {
      enable = lib.mkEnableOption "Enable font theming";

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
            name = "Material Design Icons";
            package = pkgs.material-design-icons;
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

  config = lib.mkIf cfg.enable {
    home.packages = map (font: font.package) cfg.default;
  };
}
