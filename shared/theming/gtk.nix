{
  lib,
  pkgs,
  ...
}: {
  options.custom.shared.theming.gtk = lib.mkOption {
    default = {
      theme = {
        name = "WhiteSur-Dark";
        package = pkgs.whitesur-gtk-theme;
      };

      iconTheme = {
        name = "WhiteSur-Dark";
        package = pkgs.whitesur-icon-theme;
      };
    };
  };
}
