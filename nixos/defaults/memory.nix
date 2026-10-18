_: {
  config = {
    zramSwap.enable = true;

    services.earlyoom = {
      enable = true;
      enableNotifications = true;
    };

    systemd.oomd = {
      enableSystemSlice = true;
      enableUserSlices = true;
    };
  };
}
