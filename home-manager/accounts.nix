{
  lib,
  config,
  ...
}: let
  cfg = config.custom.accounts;
in {
  options = {
    custom.accounts = {
      enable = lib.mkEnableOption "Enable email accounts";
    };
  };

  config = lib.mkIf cfg.enable {
    accounts = {
      calendar = {
        basePath = ".calendar";

        accounts = {
          # "personal" = {
          #   remote = {
          #     url = "https://radicale.sun.guusvanmeerveld.dev/mail%40guusvanmeerveld.dev/fcd3acd8-bdda-6b30-6d99-69279ed31a9e/";
          #     userName = "mail@guusvanmeerveld.dev";
          #     passwordCommand = "";
          #   };
          #
          #   thunderbird.enable = true;
          #   noctalia.enable = true;
          # };

          "work" = {
            remote = {
              type = "google_calendar";
              userName = "guusvanmeerveld@clipit.nl";
            };

            noctalia.enable = true;
          };
        };
      };
    };
  };
}
