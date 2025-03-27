{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.wayland.sway;

  package =
    if cfg.useFx
    then pkgs.swayfx
    else pkgs.sway;
in {
  imports = [./osd.nix];

  options = {
    custom.wm.wayland.sway = {
      enable = lib.mkEnableOption "Enable sway window manager";

      useFx = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.sway = {
      inherit package;

      enable = true;
    };

    custom.wm.default = {
      name = "sway";
      path = "sway";
    };

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      SDL_VIDEODRIVER = "wayland";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      WLR_DRM_NO_MODIFIERS = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };

    # Enabling realtime may improve latency and reduce stuttering, specially in high load scenarios.
    # Enabling this option allows any program run by the "users" group to request real-time priority.
    # See: https://nixos.wiki/wiki/Sway#Inferior_performance_compared_to_other_distributions
    security.pam.loginLimits = [
      {
        domain = "@users";
        item = "rtprio";
        type = "-";
        value = 1;
      }
    ];
  };
}
