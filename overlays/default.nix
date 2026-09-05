# This file defines overlays
{inputs, ...}: {
  additions = final: _prev: {
    # This one brings our custom packages from the 'pkgs' directory
    custom =
      (import ../pkgs {
        pkgs = final;
      })
      // {
        scripts = import ../scripts {pkgs = final;};
      };

    hyperx-cloud-flight-s = inputs.hyperx-cloud-flight-s.packages."${final.system}".default;
    mconnect = inputs.mconnect-nix.packages."${final.system}".default;
  };

  # https://nixos.wiki/wiki/Overlays
  modifications = _: _prev: {};
}
