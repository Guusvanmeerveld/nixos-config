{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.cli.tmux;
in {
  options = {
    custom.programs.cli.tmux = {
      enable = lib.mkEnableOption "Enable tmux terminal multiplexer";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      clock24 = true;

      tmuxp.enable = true;

      plugins = with pkgs; [
        tmuxPlugins.cpu
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = "set -g @resurrect-strategy-nvim 'session'";
        }
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '60' # minutes
          '';
        }
      ];
    };
  };
}
