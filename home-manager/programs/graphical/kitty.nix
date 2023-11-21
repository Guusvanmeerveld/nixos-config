{ configs, pkgs, ... }: {
  programs.kitty = {
    enable = true;
    theme = "Broadcast";

    font = {
      size = 14;
      name = "Fira Code";
    };
  };
}
