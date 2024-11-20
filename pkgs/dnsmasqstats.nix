{
  lib,
  pkgs,
}:
pkgs.python2Packages.buildPythonApplication rec {
  pname = "dnsmasqstats";
  version = "0.1.0";

  format = "other";

  src = pkgs.fetchFromGitHub {
    owner = "barreljan";
    repo = pname;
    rev = "5772699a33ea7eaaaf20c39ad7ea2f978eab2578";
    hash = "sha256-+/2SekcW++mFhpIwfNagFkH4MpwCuSwMToYpePkaL6o=";
  };

  installPhase = "install -Dm755 dnsmasqstats $out/bin/dnsmasqstats";

  meta = {
    description = "Dnsmasq stats full statistics, top usage of queries";
    homepage = "https://github.com/barreljan/dnsmasqstats";
    license = lib.licenses.gpl3;
    maintainers = [];

    mainProgram = "dnsmasqstats";
  };
}
