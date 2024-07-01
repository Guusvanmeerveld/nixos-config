{inputs, ...}: {
  imports = [
    inputs.nix-colors.homeManagerModules.default
  ];

  config = {
    colorScheme = inputs.nix-colors.colorSchemes.google-dark;
  };
}
