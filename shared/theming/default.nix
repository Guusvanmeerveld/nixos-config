{
  gtk = import ./gtk.nix;

  font = {
    serif = {
      name = "Inter";
      package = "inter";
    };

    monospace = {
      name = "FiraCode Nerd Font Mono";
      package = pkgs: pkgs.nerd-fonts.fira-code;
    };

    emoji = {
      name = "NotoColorEmoji";
      package = "noto-fonts-color-emoji";
    };
  };

  cursor = {
    name = "macOS";
    package = "apple-cursor";
  };
}
