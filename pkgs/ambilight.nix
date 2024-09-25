{
  lib,
  pkgs,
  ...
}: let
in
  pkgs.kodiPackages.buildKodiAddon rec {
    pname = "ambilight";
    namespace = "script.kodi.hue.ambilight";
    version = "1.0";

    src = pkgs.fetchFromGitHub {
      owner = "mpolednik";
      repo = "script.kodi.hue.ambilight";
      rev = "93af9f3eaf2957b94c05580286929e6b449ac511";
      sha256 = "sha256-EI5a4RMTbSppebQfJAR0D/lgb7qSWiWgU1GZMG9mYEE=";
    };

    propagatedBuildInputs = with pkgs.kodiPackages; [
      requests
    ];

    meta = with lib; {
      homepage = "https://github.com/mpolednik/script.kodi.hue.ambilight";
      description = "Kodi add-on for Philips Hue lights with ambilight support.";
      license = licenses.wtfpl;
    };
  }
