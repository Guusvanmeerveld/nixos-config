{lib, ...}: {
  options = {
    custom.applications.services.docker.storage = {
      storageDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib";
      };
    };
  };
}
