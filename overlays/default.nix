# This file defines overlays
_: {
  additions = final: _prev: {
    # This one brings our custom packages from the 'pkgs' directory
    custom =
      (import ../pkgs {
        pkgs = final;
      })
      // {
        scripts = import ../scripts {pkgs = final;};
      };
  };

  # https://nixos.wiki/wiki/Overlays
  modifications = _: _prev: {};
}
