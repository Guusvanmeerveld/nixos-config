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
        outputs.overlays.unstable-packages
        inputs.vscode-extensions.overlays.default
        inputs.rust-overlay.overlays.default
        inputs.nur.overlays.default
      ];
    };
  };
}
