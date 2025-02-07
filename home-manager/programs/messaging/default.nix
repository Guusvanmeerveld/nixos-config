{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.messaging;
in {
  imports = [./schildichat.nix ./vesktop.nix ./dorion.nix ./element.nix ./whatsapp.nix ./fractal.nix];

  options = {
    custom.programs.messaging = {
      enable = lib.mkEnableOption "Enable default messaging applications";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.programs.messaging = {
      fractal.enable = true;
      vesktop.enable = true;
      whatsapp.enable = true;
    };
  };
}
