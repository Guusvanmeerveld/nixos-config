{
  pkgs,
  lib,
  ...
}: {
  options.custom.shared.theming.cursor = lib.mkOption {
    default = {
      name = "macOS";
      package = pkgs.apple-cursor;
    };
  };
}
