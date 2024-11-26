# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: {
    custom =
      (import ../pkgs {pkgs = final;})
      // {
        scripts = import ../scripts {pkgs = final;};
        utils = import ../utils rec {
          pkgs = final;
          lib = pkgs.lib;
        };
      };
  };

  mconnect = final: _prev: {
    mconnect = inputs.mconnect-nix.packages."${final.system}".default;
  };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = _: _: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };

  vscode-marketplace = inputs.vscode-extensions.overlays.default;

  rust = inputs.rust-overlay.overlays.default;

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
