{
  lib,
  config,
  ...
}: {
  imports = [./sway ./clipmon.nix ./cliphist.nix];

  options = {
    custom.wm.wayland = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.custom.wm.wayland.sway.enable;
        description = "Enable Wayland";
      };
    };
  };
}
