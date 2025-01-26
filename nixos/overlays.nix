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
        outputs.overlays.mconnect
        inputs.vscode-extensions.overlays.default
        inputs.rust-overlay.overlays.default
        inputs.nur.overlays.default
      ];
    };
  };
}
