{lib, ...}: {
  options = {
    custom.hardware.video.outputs = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf (lib.types.submodule {
        options = {
          resolution = lib.mkOption {
            type = lib.types.str;
            default = "1920x1080";
          };

          refreshRate = lib.mkOption {
            type = lib.types.int;
            default = 60;
          };

          background = lib.mkOption {
            type = lib.types.str;
          };

          transform = lib.mkOption {
            type = lib.types.int;
            default = 0;
          };

          position = {
            x = lib.mkOption {
              type = lib.types.int;
              default = 0;
            };

            y = lib.mkOption {
              type = lib.types.int;
              default = 0;
            };
          };
        };
      }));

      description = "A list of the monitors currently connected to the system";

      example = {
        "HDMI-A-1" = {
          resolution = "2560x1440";
          refreshRate = 74.968;
          transform = 90;
          background = "${./monitor.jpg} stretch";
          position = {
            x = 0;
            y = 0;
          };
        };
      };
      default = {};
    };
  };
}
