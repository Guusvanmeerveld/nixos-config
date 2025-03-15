_: {
  config = {
    services.journald = {
      extraConfig = ''
        SystemMaxUse=200M
      '';
    };
  };
}
