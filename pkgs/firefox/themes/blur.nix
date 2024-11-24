{
  pkgs,
  fetchFromGitHub,
}:
pkgs.stdenv.mkDerivation rec {
  name = "firefox-mod-blur";
  version = "2.11";

  src = fetchFromGitHub {
    owner = "datguypiko";
    repo = name;
    rev = "v${version}";
    hash = "sha256-1TnR4SfObtewex4ZclgLpu5QJIR7Z1f83DKeWXQuvy0=";
  };

  buildPhase = ''
    mkdir -p $out/share/firefox

    cp userChrome.css $out/share/firefox
    cp userContent.css $out/share/firefox
    cp ASSETS $out/share/firefox -r

    cp 'EXTRA MODS/Tabs Bar Mods/Full Width Tabs/tabs_take_full_bar_width.css' $out/share/firefox
  '';
}
