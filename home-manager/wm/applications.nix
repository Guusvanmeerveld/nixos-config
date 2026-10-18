{
  lib,
  config,
  ...
}: let
  cfg = config.custom.wm.applications;
in {
  options.custom.wm.applications = with lib;
    mkOption {
      type = types.listOf (types.submodule ({config, ...}: {
        options = {
          package = mkOption {
            type = types.nullOr types.package;
            default = null;
            description = "The package for this application";
          };

          keybind = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The keybind to start this application";
          };

          executable = mkOption {
            type = types.str;
            default = lib.getExe config.package;
            description = "Executable path to start this application";
          };

          workspace = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "The workspace this application should launch on";
          };

          appId = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The WM class name to target this application";
          };

          mimeApps = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Mime apps that should be opened with this application";
          };

          desktopFile = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The corresponding desktop file for this application";
          };
        };
      }));
    };

  config.xdg.mimeApps.defaultApplications = let
    appsWithMimeApps = lib.filter (app: lib.length app.mimeApps != 0) cfg;

    mimeApps = lib.flatten (map ({
      mimeApps,
      desktopFile,
      ...
    }:
      map (mimeApp: {inherit mimeApp desktopFile;}) mimeApps)
    appsWithMimeApps);
  in
    lib.listToAttrs (map (app: {
        name = app.mimeApp;
        value = [app.desktopFile];
      })
      mimeApps);
}
