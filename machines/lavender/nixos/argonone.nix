{ inputs, config, ... }: {
  imports = [
    inputs.argonone-nix.nixosModules.default
  ];

  config = {
    programs.argon.one = {
      enable = true;

      settings = {
        fanspeed = [
          {
            temperature = 65;
            speed = 40;
          }
          {
            temperature = 75;
            speed = 70;
          }
          {
            temperature = 80;
            speed = 100;
          }
        ];
      };
    };
  };
}
