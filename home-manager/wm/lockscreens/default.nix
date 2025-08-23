{lib, ...}: {
  imports = [./swaylock.nix ./gtklock.nix];

  options = {
    custom.wm.lockscreens.default = {
      keybind = lib.mkOption {
        type = lib.types.str;
        description = "Keybind to show the lockscreen";
      };

      executable = lib.mkOption {
        type = lib.types.path;
        description = "The path to the lock screens executable file";
      };
    };
  };
}
