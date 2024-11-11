{
  config,
  lib,
  pkgs,
  ...
}: let
  extensions = config.services.vscode-server-extensions;
  cfg = config.services.vscode-server;

  extensionDir = cfg.installPath;

  extensionPath = "${extensionDir}/extensions";

  extensionJson = pkgs.vscode-utils.toExtensionJson extensions;
  extensionJsonFile = pkgs.writeTextFile {
    name = "extensions-json";
    destination = "/share/vscode/extensions/extensions.json";
    text = extensionJson;
  };
in {
  options = {
    services.vscode-server-extensions = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
    };
  };

  config = lib.mkIf cfg.enable {
    home.file = {
      "${extensionPath}".source = (
        let
          subDir = "share/vscode/extensions";
          combinedExtensionsDrv = pkgs.buildEnv {
            name = "vscode-extensions";
            paths =
              extensions
              ++ lib.singleton extensionJsonFile;
          };
        in "${combinedExtensionsDrv}/${subDir}"
      );
    };
  };
}
