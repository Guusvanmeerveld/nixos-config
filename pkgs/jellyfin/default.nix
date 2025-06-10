{pkgs}: let
  mkJellyfinPlugin = about:
    pkgs.stdenvNoCC.mkDerivation {
      pname = about.name;

      inherit (about) version src;

      installPhase = ''
        mkdir -p $out
        cp -R ./*.dll $out/.
      '';
    };
in {
  intro-skipper = let
    sub-release = "10.10";
  in
    mkJellyfinPlugin rec {
      name = "intro-skipper";
      src = pkgs.fetchzip {
        url = "https://github.com/intro-skipper/intro-skipper/releases/download/${sub-release}%2Fv${version}/intro-skipper-v${version}.zip";
        hash = "sha256-RlrZkE8108Uj5V90+jw2o5fXb+K+9/hoDcEaSkKLDGg=";
      };
      version = "1.${sub-release}.20";
    };
}
