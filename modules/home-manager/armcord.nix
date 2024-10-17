{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.armcord;
  jsonFormat = pkgs.formats.json {};
in {
  options = {
    programs.armcord = {
      enable = lib.mkEnableOption "Enable Armcord Discord client.";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.armcord;
        description = "The package to use";
      };

      settings = lib.mkOption {
        type = jsonFormat.type;
        default = {};
        example = lib.literalExpression ''
          {
          	"windowStyle": "native",
          }
        '';
        description = ''
          Configuration written to
          <filename>$XDG_CONFIG_HOME/ArmCord/storage/settings.json</filename>. See
          <link xlink:href="https://github.com/ArmCord/ArmCord/blob/dev/src/utils.ts#L41C2-L63C2"/>
          for supported values.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    xdg.configFile."armcord/storage/settings.json".source =
      jsonFormat.generate "armcord-settings" cfg.settings;
  };
}
