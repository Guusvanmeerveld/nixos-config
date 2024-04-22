{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.development.rust;
  rust = pkgs.rust-bin.stable.latest.default.override {
    extensions = ["rust-src"];
  };
in {
  options = {
    custom.applications.development.rust = {
      enable = lib.mkEnableOption "Enable Rust lang support";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [gcc pkg-config openssl.dev] ++ [rust];

    home.sessionVariables = {
      PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    };
  };
}
