{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.messaging;
in {
  imports = [./schildichat.nix ./vesktop ./dorion.nix ./element.nix ./whatsapp.nix];

  options = {
    custom.programs.messaging = {
      enable = lib.mkEnableOption "Enable default messaging applications";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.programs.messaging = {
      element.enable = true;
      vesktop.enable = true;
      whatsapp.enable = true;
    };
  };
}
