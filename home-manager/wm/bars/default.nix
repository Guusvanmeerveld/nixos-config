{lib, ...}: {
  imports = [./waybar];

  options = {
    custom.wm.bars.bars = with lib;
      mkOption {
        type = types.listOf (types.submodule ({config, ...}: {
          options = {
            package = mkOption {
              type = types.nullOr types.package;
              default = null;
              description = "The package for this application";
            };

            executable = mkOption {
              type = types.str;
              default = lib.getExe config.package;
              description = "Executable path to start this application";
            };
          };
        }));
      };
  };
}
