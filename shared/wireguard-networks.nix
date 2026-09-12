{lib, ...}: {
  options = {
    custom.shared.wireguard-networks = lib.mkOption {
      type = with lib.types;
        attrsOf
        (submodule {
          options = {
            ipRange = lib.mkOption {
              type = str;
            };

            server = {
              hostname = lib.mkOption {
                type = str;
              };

              domains = lib.mkOption {
                type = listOf str;
                default = [];
              };

              endpoint = lib.mkOption {
                type = str;
              };

              port = lib.mkOption {
                type = ints.u16;
                default = 51820;
              };

              publicKey = lib.mkOption {
                type = str;
              };

              address = lib.mkOption {
                type = str;
              };
            };

            peers = lib.mkOption {
              type = attrsOf (submodule {
                options = {
                  publicKey = lib.mkOption {
                    type = str;
                  };

                  domains = lib.mkOption {
                    type = listOf str;
                    default = [];
                  };

                  address = lib.mkOption {
                    type = str;
                  };
                };
              });
            };
          };
        });
    };
  };

  config = {
    custom.shared.wireguard-networks = {
      garden = let
        ipStart = "10.10.10";
      in {
        ipRange = "${ipStart}.0/24";

        server = {
          hostname = "sunflower";
          address = "${ipStart}.1";
          domains = ["*.sun.guusvanmeerveld.dev"];
          endpoint = "wireguard.guusvanmeerveld.dev";
          publicKey = "cuSlka1YtuRd1GX3mVrbcI2Ig9plLt1lQtDf9Ehs0Bc="; # pragma: allowlist secret
        };

        peers = {
          desktop = {
            publicKey = "dVOXBUprtiJSOMazEujx0zh7m86YEoXDdQ3muMpQIHw="; # pragma: allowlist secret
            address = "${ipStart}.2";
          };

          laptop = {
            publicKey = "4cfYFYG7zvU+Hy1hVRT1rbNBbeVXCKy9GoRP6Mpv738="; # pragma: allowlist secret
            address = "${ipStart}.3";
          };

          phone = {
            publicKey = "/JKDqqU3tVqKJP4tlcOol5VacFu0Ea4cLRwMjFbqj1M="; # pragma: allowlist secret
            address = "${ipStart}.4";
          };

          thuisthuis = {
            publicKey = "6lNZjXUkvfdG1prJVJh7yl32yRU1j+2+Suhyq8XySmU="; # pragma: allowlist secret
            address = "${ipStart}.6";
          };

          daisy = {
            publicKey = "WvESBhla1yU9irR4izmGRJuifyrFT47Qry1JsLgcXhY="; # pragma: allowlist secret
            address = "${ipStart}.7";
            domains = ["*.daisy.guusvanmeerveld.dev"];
          };

          cattle = {
            publicKey = "1QdndFE7pZAGA47U0O/1VErl3VNZnRFMNY+xksX9HAQ="; # pragma: allowlist secret
            address = "${ipStart}.9";
          };

          chimpanzee = {
            publicKey = "NW5fh6w2GjK+gXlZvkIq1MrPNOhvTxHF7iKDiWiWEwg="; # pragma: allowlist secret
            address = "${ipStart}.11";
          };

          framework-13 = {
            publicKey = "3UWmaWdtyboiSfib2i33TmUZcV6t6eogzsGv2BCIZXs="; # pragma: allowlist secret
            address = "${ipStart}.12";
          };

          oribi = {
            publicKey = "0Ce9BqYxPmYjvf/y0ydZecx5S5UYMuYW/LtZoA3xjBE="; # pragma: allowlist secret
            address = "${ipStart}.14";
          };

          lavender = {
            publicKey = "BLrQSVGvczwkxO5ufkLAK5z+FQLdSXqDTXArclNvzxc="; # pragma: allowlist secret
            address = "${ipStart}.15";
            domains = ["*.lav.guusvanmeerveld.dev"];
          };

          antelope = {
            publicKey = "/M8h0RzVdsE7j9svlKGGXNxf7lFk7iR6Kt3mSZBp03k="; # pragma: allowlist secret
            address = "${ipStart}.16";
          };

          allium = {
            publicKey = "I2dCa+Xi1KcT9bk14VWcv0r9uizOLraEN+twAIzBxHo="; # pragma: allowlist secret
            address = "${ipStart}.17";
          };

          crocus = {
            publicKey = "UjJqjYvUcSl4dGcfRgPWAyNHvHPqo51MApKixc+h3RQ="; # pragma: allowlist secret
            address = "${ipStart}.18";
            domains = ["*.crocus.guusvanmeerveld.dev"];
          };
        };
      };
    };
  };
}
