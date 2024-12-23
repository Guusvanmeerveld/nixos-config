{
  pkgs,
  fetchFromGitHub,
}:
pkgs.stdenv.mkDerivation rec {
  name = "firefox-mod-blur";
  version = "2.14";

  src = fetchFromGitHub {
    owner = "datguypiko";
    repo = name;
    rev = "v${version}";
    hash = "sha256-Pc2BQuHYDtKexQKwT2wpphRAFuW29grZoCuqzG/xYLM=";
  };

  buildPhase = ''
    mkdir -p $out/share/firefox

    cp userChrome.css $out/share/firefox
    cp userContent.css $out/share/firefox
    cp ASSETS $out/share/firefox -r

    cp 'EXTRA MODS/Tabs Bar Mods/Full Width Tabs/tabs_take_full_bar_width.css' $out/share/firefox
  '';
}
