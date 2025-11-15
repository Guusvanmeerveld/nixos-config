{
  lib,
  config,
  # pkgs,
  ...
}: let
  cfg = config.custom.programs.eduvpn;
in {
  options = {
    custom.programs.eduvpn = {
      enable = lib.mkEnableOption "Enable EduVPN client";
    };
  };

  config = lib.mkIf cfg.enable {
    # TODO: enable eduvpn-client when it is fixed
    # home.packages = with pkgs; [eduvpn-client];
  };
}
