{
  lib,
  buildGoModule,
  fetchFromGitHub,
  writeText,
  pkg-config,
  gtk3,
  gtk-layer-shell,
  wrapGAppsHook,
}: let
  hotspotCssFile = writeText "" ''
    window {
      background-color: rgba (0, 0, 0, 0);
      border: none
    }
  '';
in
  buildGoModule rec {
    pname = "nwg-dock";
    version = "0.4.1";

    src = fetchFromGitHub {
      owner = "nwg-piotr";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-ZR72QMftR6bWCieJHW3k46Ujdn/W5fulGxYKoNPiPfE=";
    };

    vendorHash = "sha256-paRcBQwg2uGouMRX5XF++OyN8Y0JyucXLN0G5O0j3qA=";

    ldflags = ["-s" "-w"];

    nativeBuildInputs = [pkg-config wrapGAppsHook];
    buildInputs = [gtk3 gtk-layer-shell];

    postPatch = ''
      substituteInPlace main.go --replace 'filepath.Join(dataHome, "nwg-dock/hotspot.css")' '"${hotspotCssFile}"'
    '';

    meta = with lib; {
      description = "GTK3-based dock for sway";
      homepage = "https://github.com/nwg-piotr/nwg-dock";
      license = licenses.mit;
      platforms = platforms.linux;
      maintainers = with maintainers; [dit7ya];
      mainProgram = "nwg-dock";
    };
  }
