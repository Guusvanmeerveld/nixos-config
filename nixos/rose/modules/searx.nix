{...}: {
  config = {
    services.searx = {
      enable = true;

      settings = {
        use_default_settings = true;

        server = {
          port = 8081;
          bind_address = "0.0.0.0";
          secret_key = "@SEARX_SECRET_KEY@";
        };

        ui = {
          infinite_scroll = true;
          center_alignment = true;
          query_in_title = true;
        };

        general = {
          instance_name = "SearX Search Engine";
        };
      };

      environmentFile = "/var/lib/searx.env";
    };
  };
}
