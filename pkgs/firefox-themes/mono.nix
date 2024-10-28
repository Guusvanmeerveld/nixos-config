{
  pkgs,
  fetchFromGitHub,
}:
pkgs.stdenv.mkDerivation rec {
  name = "Mono-firefox-theme";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "witalihirsch";
    repo = name;
    rev = "111c1c4768deb36b224febd29cc7a5517a162675";
    hash = "sha256-0i90s/9WruvJQm3YoI4J7zsAdkJhTH0OGp5jwOaZINQ=";
  };

  buildPhase = ''
    mkdir -p $out/local/share

    cp firefox $out/local/share -r
  '';
}
