{
  gtk = import ./gtk.nix;

  font = {
    serif = {
      name = "SFProText Nerd Font";
      package = "sf-pro-nerd";
    };

    monospace = {
      name = "FiraCode Nerd Font Mono";
      package = "fira-code-nerdfont";
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
