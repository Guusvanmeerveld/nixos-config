{pkgs}: {
  config = {
    services.dnsmasq = {
      enable = true;

      resolveLocalQueries = false;

      settings = {
        domain-needed = true;

        resolv-file = pkgs.writeFile "resolve.conf" ''
          9.9.9.9
          149.112.112.112
          2620:fe::fe
          2620:fe::9
        '';
      };
    };
  };
}
