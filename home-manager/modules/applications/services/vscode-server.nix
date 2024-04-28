{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.services.vscode-server;
in {
  imports = [
    inputs.vscode-server.homeModules.default
  ];

  options = {
    custom.applications.services.vscode-server = {
      enable = lib.mkEnableOption "Enable VSCode server protocol";
    };
  };

  config = lib.mkIf cfg.enable {
    services.vscode-server = {
      enable = true;
      installPath = "$HOME/.vscodium-server";
    };

    home.packages = with pkgs; [alejandra nil];
  };
}
