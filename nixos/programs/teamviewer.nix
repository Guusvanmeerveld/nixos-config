{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.teamviewer;
in {
  options = {
    custom.programs.teamviewer = {
      enable = lib.mkEnableOption "Enable TeamViewer remote desktop interface";
    };
  };

  config = lib.mkIf cfg.enable {
    services.teamviewer = {
      enable = true;
      package = with pkgs;
        symlinkJoin {
          name = "teamviewer-wrapped";
          paths = [teamviewer];
          buildInputs = [makeWrapper];

          postFixup = ''
            wrapProgram $out/share/teamviewer/tv_bin/script/teamviewer \
              --unset QT_QPA_PLATFORM
          '';
        };
    };
  };
}
