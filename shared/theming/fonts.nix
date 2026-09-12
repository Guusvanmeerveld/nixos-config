{
  lib,
  pkgs,
  ...
}: {
  options.custom.shared.theming.fonts = lib.mkOption {
    default = {
      serif = {
        name = "Inter";
        package = pkgs.inter;
      };

      monospace = {
        name = "FiraCode Nerd Font Mono";
        package = pkgs.nerd-fonts.fira-code;
      };

      emoji = {
        name = "NotoColorEmoji";
        package = pkgs.noto-fonts-color-emoji;
      };
    };
  };
}
