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
  intro-skipper = pkgs.callPackage ./intro-skipper {};

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
