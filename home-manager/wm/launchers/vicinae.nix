{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.custom.wm.launchers.vicinae;
in {
  options = {
    custom.wm.launchers.vicinae = {
      enable = lib.mkEnableOption "Enable Vicinae application launcher";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.applications = [
      {
        executable = "${lib.getExe config.programs.vicinae.package} toggle";
        keybind = "$mod+space";
      }
    ];

    programs.vicinae = {
      enable = true;

      settings = {
        keybinding = "vim";
        tray.enabled = false;
        launcher_window.opacity = 0.9;
      };

      systemd = {
        enable = true;
        target = config.wayland.systemd.target;
      };

      extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [nix wifi-commander bitwarden];
    };
  };
}
