{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.wayvnc;
in {
  options = {
    custom.services.wayvnc = {
      enable = lib.mkEnableOption "Enable wayvnc";
    };
  };

  config = lib.mkIf cfg.enable {
    services.wayvnc = {
      enable = true;
      autoStart = true;

      settings = {
        address = "localhost";
        port = 5901;

        use_relative_paths = true;
        rsa_private_key_file = "rsa_key.pem";
      };
    };
  };
}
