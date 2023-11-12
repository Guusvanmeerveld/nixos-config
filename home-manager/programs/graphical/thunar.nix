{ pkgs, ... }: {
  home.packages = with pkgs; [ xfce.thunar ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "thunar.desktop" ];
    };
  };

}
