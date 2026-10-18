{
  outputs,
  inputs,
  ...
}: {
  config = {
    nixpkgs = {
      overlays = [
        outputs.overlays.additions
        outputs.overlays.modifications
        inputs.nur.overlays.default
        inputs.nix-cachyos-kernel.overlays.pinned
      ];
    };
  };
}
