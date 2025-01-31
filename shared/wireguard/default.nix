{
  networks = {
    garden = {
      server = {
        publicKey = "UjJqjYvUcSl4dGcfRgPWAyNHvHPqo51MApKixc+h3RQ=";
        address = "10.10.10.1";
        endpoint = "143.47.189.158";
        port = 51820;
      };

      clients = {
        desktop = {
          publicKey = "dVOXBUprtiJSOMazEujx0zh7m86YEoXDdQ3muMpQIHw=";
          address = "10.10.10.2";
        };

        laptop = {
          publicKey = "4cfYFYG7zvU+Hy1hVRT1rbNBbeVXCKy9GoRP6Mpv738=";
          address = "10.10.10.3";
        };

        phone = {
          publicKey = "/JKDqqU3tVqKJP4tlcOol5VacFu0Ea4cLRwMjFbqj1M=";
          address = "10.10.10.4";
        };

        tulip = {
          publicKey = "/7j5rVEgQVe4eVY6v/DkA+tn/IXqxH+X7641iAPPa38=";
          address = "10.10.10.5";
          keepAlive = true;
        };

        thuisthuis = {
          publicKey = "6lNZjXUkvfdG1prJVJh7yl32yRU1j+2+Suhyq8XySmU=";
          address = "10.10.10.6";
        };
      };
    };
  };
}
