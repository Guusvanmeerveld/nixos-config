{
  outputs,
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
    outputs.homeManagerModules.vscode-server
  ];

  options = {
    custom.applications.services.vscode-server = {
      enable = lib.mkEnableOption "Enable VSCode server protocol";
    };
  };

  config = lib.mkIf cfg.enable {
    services.vscode-server = {
      enable = true;
      # enableFHS = true;

      extensions = with pkgs.vscode-marketplace; [
        jnoortheen.nix-ide
      ];

      installPath = "$HOME/.vscodium-server";
    };

    home.packages = with pkgs; [alejandra nil];
  };
}
