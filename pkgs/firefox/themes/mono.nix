{
  pkgs,
  fetchFromGitHub,
}: let
  fixCenterTabTitle = ''
    .tab-icon-stack {
      margin-inline-start: auto
    }

    .tab-label-container {
      max-width: min-content;
      margin-inline-end: auto;
    }

    .tab-label-container.proton {
      display: grid !important;
      justify-items: safe center !important;
      text-align: center !important;
    }

    .tab-label {
      overflow: hidden !important;
      text-align: center !important;
    }
  '';
in
  pkgs.stdenv.mkDerivation rec {
    name = "Mono-firefox-theme";
    version = "0.6";

    src = fetchFromGitHub {
      owner = "witalihirsch";
      repo = name;
      rev = "111c1c4768deb36b224febd29cc7a5517a162675";
      hash = "sha256-0i90s/9WruvJQm3YoI4J7zsAdkJhTH0OGp5jwOaZINQ=";
    };

    postPatch = ''
      echo "${fixCenterTabTitle}" >> firefox/userChrome.css
    '';

    buildPhase = ''
      mkdir -p $out/local/share

      cp firefox $out/local/share -r
    '';
  }
