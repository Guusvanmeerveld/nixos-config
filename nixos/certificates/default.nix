{
  config,
  lib,
  ...
}: let
  cfg = config.custom.certificates;
in {
  options = let
    inherit (lib) mkEnableOption;
  in {
    custom.certificates = {
      enable = mkEnableOption "Enable custom certificates";
    };
  };

  config = let
    inherit (lib) mkIf readFile;
  in
    mkIf cfg.enable {
      security.pki.certificates = [
        (readFile ./tulip.crt)
        (readFile ./orchid.crt)
      ];
    };
}
