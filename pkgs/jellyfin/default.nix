{pkgs}: let
  nativeBuildInputs = with pkgs; [unzip];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir -p $out
    cp -R ./*.dll $out/.
  '';
in {
  intro-skipper = let
    sub-release = "10.10";
  in
    pkgs.stdenvNoCC.mkDerivation rec {
      pname = "jellyfin-plugin-intro-skipper";

      src = pkgs.fetchurl {
        url = "https://github.com/intro-skipper/intro-skipper/releases/download/${sub-release}%2Fv${version}/intro-skipper-v${version}.zip";
        hash = "sha256-c7WllWk+VtWIQgh6f40qvqZQ+I+4CT2ialHCno12IYI=";
      };

      version = "1.${sub-release}.23";

      inherit nativeBuildInputs unpackPhase installPhase;
    };

  trakt = let
    major-version = "26";
  in
    pkgs.stdenvNoCC.mkDerivation rec {
      pname = "jellyfin-plugin-trakt";

      version = "${major-version}.0.0.0";

      src = pkgs.fetchurl {
        url = "https://github.com/jellyfin/jellyfin-plugin-trakt/releases/download/v${major-version}/trakt_${version}.zip";
        hash = "sha256-XJQv4K3heoGE9D2nqxiR2+I0bCkyxg4JA0GI5nDDAEo=";
      };

      inherit nativeBuildInputs unpackPhase installPhase;
    };

  listen-brainz = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "jellyfin-plugin-listenbrainz";

    version = "5.2.0.4";

    src = pkgs.fetchurl {
      url = "https://github.com/lyarenei/jellyfin-plugin-listenbrainz/releases/download/${version}/listenbrainz_${version}.zip";
      hash = "sha256-dGMwRlga3lPTxXEK+EBXvqtEvDzHDzllOqi+LaUCcLk=";
    };

    inherit nativeBuildInputs unpackPhase installPhase;
  };

  dlna = pkgs.callPackage ./dlna {};
}
