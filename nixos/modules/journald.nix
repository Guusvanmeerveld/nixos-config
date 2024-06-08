{...}: {
  config = {
    services.journald = {
      extraConfig = ''
        MaxFileSec=14day
      '';
    };
  };
}
