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
          publicKey = "uJ22ivJZjCd1jvPpR/Bi+lTYn7G3HkQ/WDki7tuQEBM=";
          address = "10.10.10.3";
        };

        phone = {
          publicKey = "/JKDqqU3tVqKJP4tlcOol5VacFu0Ea4cLRwMjFbqj1M=";
          address = "10.10.10.4";
        };

        tulip = {
          publicKey = "b9u6DlIrzek+RTskFXKTmaEIT5tvc+7w86N5tn5ILVM=";
          address = "10.10.10.5";
        };
      };
    };
  };
}
