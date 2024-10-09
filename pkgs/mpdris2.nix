{
  lib,
  pkgs,
}:
pkgs.python3Packages.buildPythonApplication rec {
  pname = "mpDris2";
  version = "0.9.1";

  pyproject = false;

  src = pkgs.fetchFromGitHub {
    owner = "eonpatapon";
    repo = pname;
    rev = "4a7dc031ca6b3f944983deede5309237115e27c4";
    hash = "sha256-oY5iwmXQyEwJiOsDaKY8uH2hFlP3QM/b1ApPrUBdqx8=";
  };

  build-system = with pkgs; [
    autoreconfHook
    intltool
    wrapGAppsHook
  ];

  dependencies = with pkgs.python3Packages; [mpd2 dbus-python pygobject3 mutagen];

  meta = {
    description = "MPRIS V2.1 support for mpd";
    homepage = "https://github.com/eonpatapon/mpDris2";
    license = lib.licenses.gpl3;
    maintainers = [];

    mainProgram = "mpDris2";
  };
}
