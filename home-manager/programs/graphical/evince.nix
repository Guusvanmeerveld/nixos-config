{ pkgs, ... }: {
  home.packages = with pkgs; [ evince ];

  xdg.mimeApps = {
    defaultApplications = {
      "application/pdf" = [ "evince.desktop" ];
    };
  };

}
