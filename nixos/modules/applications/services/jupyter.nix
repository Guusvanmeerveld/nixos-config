{
  outputs,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.services.jupyter;
in {
  imports = [outputs.nixosModules.jupyter];

  options = {
    custom.applications.services.jupyter = {
      enable = lib.mkEnableOption "Enable the Jupyter notebook web service";

      port = lib.mkOption {
        type = lib.types.int;
        default = 3769;
        description = "The port to run the service on";
      };

      passwordFile = lib.mkOption {
        type = lib.types.path;
        description = "The path to the password file";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        description = "The external domain used to connect to this service";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      jupyter-server = {
        enable = true;

        password = "open(${cfg.passwordFile}, 'r', encoding='utf8').read().strip()";

        port = cfg.port;

        notebookConfig = ''
          c.ServerApp.allow_password_change = False
          c.ServerApp.allow_remote_access = True
        '';

        kernels = {
          python3 = let
            env = pkgs.python3.withPackages (pythonPackages:
              with pythonPackages; [
                pandas
                numpy
                scikit-learn
                matplotlib
                ipykernel
                jupyter
                scipy
                autopep8
                seaborn
              ]);
          in {
            displayName = "Python 3 for machine learning";
            argv = [
              "${env.interpreter}"
              "-m"
              "ipykernel_launcher"
              "-f"
              "{connection_file}"
            ];
            language = "python";
            # logo32 = "${env.sitePackages}/ipykernel/resources/logo-32x32.png";
            # logo64 = "${env.sitePackages}/ipykernel/resources/logo-64x64.png";
          };
        };
      };

      nginx = lib.mkIf config.services.nginx.enable {
        virtualHosts = {
          "${cfg.domain}" = {
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              proxyPass = "http://localhost:${toString cfg.port}/";
              recommendedProxySettings = true;
            };
          };
        };
      };
    };
  };
}
