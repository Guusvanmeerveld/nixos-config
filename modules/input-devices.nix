{ config, pkgs, ... }:
{
  services.xserver.libinput = {
    mouse = {
      accelProfile = "flat";
      accelSpeed = "-0.25";
    };

    touchpad = {
      naturalScrolling = true;
      accelProfile = "flat";
    };
  };
}

