{lib, ...}: {
  imports = [./swaylock.nix];

  options = {
    custom.wm.lockscreens.default = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "The lock screens name";
      };

      path = lib.mkOption {
        type = lib.types.str;
        description = "The path to the lock screens executable file";
      };
    };
  };
}
