{
  outputs,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.services.jupyter;
in {
  imports = [outputs.nixosModules.jupyter];

  options = {
    custom.services.jupyter = {
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

        password = "open('${cfg.passwordFile}', 'r', encoding='utf8').read().strip()";

        port = cfg.port;

        notebookConfig = ''
          c.ServerApp.allow_remote_access = True
        '';

        kernels = {
          deeplearning = let
            env = pkgs.python3.withPackages (pythonPackages:
              with pythonPackages;
                [
                  ipykernel
                  jupyter

                  pandas
                  numpy
                  scipy

                  seaborn
                  matplotlib

                  pillow

                  scikit-learn
                  pytorch
                  torchvision

                  nltk
                ]
                ++ [pkgs.textblob]);
          in {
            displayName = "Python 3 for Deep learning";
            argv = [
              "${env.interpreter}"
              "-m"
              "ipykernel_launcher"
              "-f"
              "{connection_file}"
            ];
            language = "python";
          };
          bayesian = let
            env = pkgs.python3.withPackages (pythonPackages:
              (with pythonPackages; [
                ipykernel
                jupyter

                pandas
                numpy
                scipy

                seaborn
                matplotlib

                scikit-learn
              ])
              ++ [pkgs.pyjags]);
          in {
            displayName = "Python 3 for Bayesian statistics";
            argv = [
              "${env.interpreter}"
              "-m"
              "ipykernel_launcher"
              "-f"
              "{connection_file}"
            ];
            language = "python";
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
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };
}
