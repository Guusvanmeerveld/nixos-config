{lib, ...}: {
  imports = lib.custom.umport {
    paths = [
      ../modules/nixos
      ./.
    ];
    exclude = [./default.nix];
  };
}
