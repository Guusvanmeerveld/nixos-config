{lib, ...}: {
  imports = [./mako.nix ./swaync.nix ./dunst.nix];
  options = {
    custom.wm.notifications = {
      default = {
        name = lib.mkOption {
          type = lib.types.str;
          description = "The notification managers name";
        };

        path = lib.mkOption {
          type = lib.types.str;
          description = "The path to the notification managers executable file";
        };
      };

      hub = {
        path = lib.mkOption {
          type = lib.types.str;
          description = "The path to the notification managers executable file";
        };
      };
    };
  };
}
