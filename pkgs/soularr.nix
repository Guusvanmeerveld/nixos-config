{
  lib,
  pkgs,
  slskd-api,
}:
pkgs.python3Packages.buildPythonApplication rec {
  pname = "soularr";
  version = "0.1.0";

  pyproject = false;

  src = pkgs.fetchFromGitHub {
    owner = "mrusse";
    repo = pname;
    rev = "bb7199ad4303942b3651524d7132e6e5c9032767";
    hash = "sha256-zwYwwGwIgw8LPrk04UxUW2Wl6l42mcFa1QKmYdZL0JM=";
  };

  dependencies = (with pkgs.python3Packages; [music-tag pyarr]) ++ [slskd-api];

  installPhase = "install -Dm755 soularr.py $out/bin/soularr";

  meta = {
    description = "A Python script that connects Lidarr with Soulseek!";
    homepage = "https://github.com/mrusse/soularr";
    license = lib.licenses.gpl3;
    maintainers = [];

    mainProgram = "soularr";
  };
}
