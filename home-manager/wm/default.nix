{lib, ...}: {
  imports = [./X11 ./wayland ./bars ./lockscreens ./notifications ./docks];

  options = {
    custom.wm = {
      default = {
        name = lib.mkOption {
          type = lib.types.str;
          description = "The window managers name";
        };

        path = lib.mkOption {
          type = lib.types.str;
          description = "The path to the window managers executable file";
        };
      };
    };
  };
}
