{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.vscode-server;

  extensionDir = "vscodium-server";

  extensionPath = ".${extensionDir}/extensions";

  extensionJson = pkgs.vscode-utils.toExtensionJson cfg.extensions;
  extensionJsonFile = pkgs.writeTextFile {
    name = "extensions-json";
    destination = "/share/vscode/extensions/extensions.json";
    text = extensionJson;
  };
in {
  options = {
    services.vscode-server = {
      extensions = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
      };
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
              cfg.extensions
              ++ extensionJsonFile;
          };
        in "${combinedExtensionsDrv}/${subDir}"
      );
    };
  };
}
