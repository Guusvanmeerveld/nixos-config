# This file defines overlays
{inputs, ...}: {
  additions = final: _prev: {
    # This one brings our custom packages from the 'pkgs' directory
    custom =
      (import ../pkgs {pkgs = final;})
      // {
        scripts = import ../scripts {pkgs = final;};
        utils = import ../utils rec {
          pkgs = final;
          lib = pkgs.lib;
        };
      };

    suyu = inputs.suyu.packages."${final.system}".default;
    hyperx-cloud-flight-s = inputs.hyperx-cloud-flight-s.packages."${final.system}".default;
    mconnect = inputs.mconnect-nix.packages."${final.system}".default;
    sf-pro = inputs.apple-fonts.packages."${final.system}".sf-pro;
  };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    eduvpn-client = prev.eduvpn-client.overrideAttrs (old: {
      # Fix .desktop file and icons not being discovered
      postInstall = ''
        cp $out/lib/python3.12/site-packages/eduvpn/data/share $out -r
      '';
    });

    whatsie = prev.whatsie.overrideAttrs (old: {
      # Fix .desktop file and icons not being discovered
      postInstall = ''
        mkdir -p $out/share/{applications,icons} -p
        cp $src/dist/linux/*.desktop $out/share/applications -r
        cp $src/dist/linux/hicolor $out/share/icons -r
      '';
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
