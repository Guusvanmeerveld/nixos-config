{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.development.rust;
in {
  options = {
    custom.applications.development.rust = {
      enable = lib.mkEnableOption "Enable Rust lang support";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [pkgs.rust-bin.stable.latest.default gcc];
  };
}
