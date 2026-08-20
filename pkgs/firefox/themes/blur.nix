{
  pkgs,
  fetchFromGitHub,
}:
pkgs.stdenv.mkDerivation rec {
  pname = "firefox-mod-blur";
  version = "2.64";

  src = fetchFromGitHub {
    owner = "datguypiko";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-ENVVA77CleGVX2UzhwZoNhpTnGh7WyMCPYtFdamomas=";
  };

  buildPhase = ''
    mkdir -p $out/share/firefox

    cp userChrome.css $out/share/firefox
    cp userContent.css $out/share/firefox
    cp ASSETS $out/share/firefox -r

    # cp 'EXTRA MODS/Tabs Bar Mods/Full Width Tabs/tabs_take_full_bar_width.css' $out/share/firefox
  '';
}
