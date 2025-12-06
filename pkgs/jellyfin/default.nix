{pkgs}: {
  intro-skipper = pkgs.callPackage ./intro-skipper {};

  trakt = pkgs.callPackage ./trakt {};

  listenbrainz = pkgs.callPackage ./listenbrainz {};

  lyrics = pkgs.callPackage ./lyrics {};

  dlna = pkgs.callPackage ./dlna {};
}
