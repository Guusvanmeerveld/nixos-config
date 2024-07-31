{
  pkgs,
  lib,
}:
with pkgs;
  stdenv.mkDerivation rec {
    pname = "mconnect";
    version = "0.0";

    src = fetchFromGitHub {
      owner = "grimpy";
      repo = pname;

      rev = "399115003fe71a0d310e1166c4eb8f05c40a0a90";
      hash = "sha256-WzbCu+yuNGodkxeuOAUn6ceFpCnZRaiQFFpHaiLw6Wc=";
    };

    nativeBuildInputs = [meson vala cmake pkg-config ninja wrapGAppsHook];
    buildInputs = [glib json-glib libgee libnotify glib-networking gtk3 gnutls gdb xorg.libX11 xorg.libXtst at-spi2-atk gdk-pixbuf];

    meta = with lib; {
      description = "KDE Connect protocol implementation in Vala/C ";
      platforms = platforms.linux;
    };
  }
