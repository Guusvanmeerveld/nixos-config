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
        allowRemoteAccess = true;

        port = cfg.port;

        kernels = {
          python3 = let
            pyjags = pkgs.python311.pkgs.buildPythonPackage
              rec {
                pname = "pyjags";
                version = "1.3.8";
                format = "pyproject";

                nativeBuildInputs = with pkgs; [
                  python311.pkgs.flit-core
                  pkg-config
                ];

                propagatedBuildInputs = with pkgs.python311.pkgs;
                  [
                    setuptools
                    numpy
                    pybind11
                    arviz
                    deepdish
                  ] ++ (with pkgs; [
                    jags
                  ]);

                src = pkgs.fetchFromGitHub {
                  owner = "michaelnowotny";
                  repo = "pyjags";
                  rev = "9fc67d2b9d17b629a05ce2edc79567802a95aa1f";
                  hash = "sha256-LkNUs13feb6p1NZ7Cucy0UDS9VjSP2ytw1G1bKwystI=";
                };
              };

              env = pkgs.python3.withPackages (pythonPackages:
                (with pythonPackages; [
                  ipykernel
                  jupyter-collaboration
                  jupyter

                  pandas
                  numpy
                  scipy

                  seaborn
                  matplotlib
                  
                  scikit-learn
                ]) ++ [pyjags]);
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
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };
}
