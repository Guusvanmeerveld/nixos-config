{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) getExe;

  cfg = config.programs.tidal-hifi;
  jsonFormat = pkgs.formats.json {};

  settingsFile = jsonFormat.generate "tidal-hifi-settings" cfg.settings;
  jq = getExe pkgs.jq;

  updateScript = pkgs.writeScript "tidal-config-update" ''
    config=$(${jq} -s '.[0] + .[1]' ${cfg.configLocation} ${settingsFile})
    echo $config > ${cfg.configLocation}
  '';
in {
  options = {
    programs.tidal-hifi = {
      enable = lib.mkEnableOption "Enable Tidal Hifi client";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.tidal-hifi;
        description = "The package to use";
      };

      configLocation = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/.config/tidal-hifi/config.json";
      };

      settings = lib.mkOption {
        inherit (jsonFormat) type;
        default = {};
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    home.activation = lib.mkIf (cfg.settings != {}) {
      tidalConfigUpdate = lib.hm.dag.entryAfter ["writeBoundary"] ''
        run ${updateScript}
      '';
    };
  };
}
