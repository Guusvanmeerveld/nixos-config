_: {
  config = {
    services.journald.settings.Journal = {
      SystemMaxUse = "200M";
    };
  };
}
