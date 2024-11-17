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
    outputs.homeManagerModules.vscode-server.extensions
  ];

  options = {
    custom.applications.services.vscode-server = {
      enable = lib.mkEnableOption "Enable VSCode server protocol";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      vscode-server = {
        enable = true;
        # enableFHS = true;

        installPath = "${config.home.homeDirectory}/.vscodium-server";
      };

      vscode-server-extensions = with pkgs.vscode-marketplace; [
        jnoortheen.nix-ide
      ];
    };

    home.packages = with pkgs; [alejandra nixd];
  };
}