{lib, ...}: {
  options = {
    custom.applications.services.docker.networking = {
      internalNetworkName = lib.mkOption {
        type = lib.types.str;
        default = "intranet";
      };

      externalNetworkName = lib.mkOption {
        type = lib.types.str;
        defualt = "internet";
      };
    };
  };
}
