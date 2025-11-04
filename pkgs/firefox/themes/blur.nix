{
  pkgs,
  fetchFromGitHub,
}:
pkgs.stdenv.mkDerivation rec {
  pname = "firefox-mod-blur";
  version = "2.19";

  src = fetchFromGitHub {
    owner = "datguypiko";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-+UqtBLJwEQTkT9Rxd7T7L1M9Dp6NNwEr6jjJBOtG0Wo=";
  };

  buildPhase = ''
    mkdir -p $out/share/firefox

    cp userChrome.css $out/share/firefox
    cp userContent.css $out/share/firefox
    cp ASSETS $out/share/firefox -r

    # cp 'EXTRA MODS/Tabs Bar Mods/Full Width Tabs/tabs_take_full_bar_width.css' $out/share/firefox
  '';
}
