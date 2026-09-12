{lib, ...}: {
  imports = lib.custom.umport {
    paths = [
      (lib.custom.relativeToRoot "modules/nixos")
      (lib.custom.relativeToRoot "shared")
      ./.
    ];
    exclude = [./default.nix];
  };
}
