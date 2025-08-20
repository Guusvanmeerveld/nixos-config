{lib, ...}: {
  imports = [./X11 ./wayland ./bars ./lockscreens ./notifications ./docks ./widgets ./launchers];

  options = {
    custom.wm = {
      applications = with lib;
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
            };
          }));
        };
    };
  };
}
