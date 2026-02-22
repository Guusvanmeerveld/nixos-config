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
        utils = import ../utils rec {
          pkgs = final;
          inherit (pkgs) lib;
        };
      };

    hyperx-cloud-flight-s = inputs.hyperx-cloud-flight-s.packages."${final.system}".default;
    mconnect = inputs.mconnect-nix.packages."${final.system}".default;
  };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = _: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    # eduvpn-client = prev.eduvpn-client.overrideAttrs (_old: {
    #   # Fix .desktop file and icons not being discovered
    #   postInstall = ''
    #     cp $out/lib/python3.12/site-packages/eduvpn/data/share $out -r
    #   '';
    # });

    # xdg-desktop-portal-wlr = prev.xdg-desktop-portal-wlr.overrideAttrs (_old: {
    #   patches = [
    #     (final.fetchpatch {
    #       url = "https://github.com/emersion/xdg-desktop-portal-wlr/commit/2099d31d1a9fb969b7d781d64d4ed48a17ddd4db.patch";
    #       hash = "sha256-g4esAs4HfQH4vTUcG2L0WhA92RFqDrOGmcGRdXWD1KE=";
    #     })
    #   ];
    # });

    # electron_36 = final.electron_37;

    whatsie = prev.whatsie.overrideAttrs (_old: {
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
  # unstable-packages = final: _prev: {
  #   unstable = import inputs.nixpkgs-unstable {
  #     inherit (final) system;
  #     config.allowUnfree = true;
  #   };
  # };
}
