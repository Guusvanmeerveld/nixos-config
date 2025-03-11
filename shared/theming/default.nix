{
  gtk = import ./gtk.nix;

  font = {
    serif = {
      name = "SF Pro Text";
      package = "sf-pro";
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
