{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  coreutils,
  writeScript,
  buildFHSEnv,
}: let
  package = buildDotnetModule (finalAttrs: {
    pname = "samsung-jellyfin-installer";
    version = "2.2.0.3";

    src = fetchFromGitHub {
      owner = "Jellyfin2Samsung";
      repo = "Samsung-Jellyfin-Installer";
      tag = "v${finalAttrs.version}";
      hash = "sha256-pDzw2/cGpJAStnNOTiIvmyvRHNwEY2Ezz1JdDKwydYA=";
    };

    postPatch = ''
      find Jellyfin2Samsung-CrossOS -type f -name "*.cs" -exec sed -i 's|AppContext.BaseDirectory|Environment.GetEnvironmentVariable("JELLYFIN2SAMSUNG_HOME")|g' {} +
    '';

    projectFile = [
      "Jellyfin2Samsung-CrossOS/Jellyfin2Samsung.csproj"
    ];

    executables = ["Jellyfin2Samsung"];

    nugetDeps = ./deps.json;

    meta = {
      description = "One-click install of Jellyfin on your Samsung TV - fully compatible with all Tizen versions";
      homepage = "https://github.com/Jellyfin2Samsung/Samsung-Jellyfin-Installer";
      license = lib.licenses.mit;
      # maintainers = with lib.maintainers; [];
      mainProgram = "Jellyfin2Samsung";
      platforms = lib.platforms.all;
    };
  });
in
  buildFHSEnv {
    # Wrap in FHS env because program downloads a Tizen CLI tool which cannot natively be run in NixOS, but it essential to the functionality of the program.
    name = "samsung2jellyfin";

    targetPkgs = pkgs: (with pkgs; [
      zlib
      openssl
    ]);

    runScript = writeScript "start-jellyfin2samsung" ''
      export JELLYFIN2SAMSUNG_HOME="$HOME/.config/Jellyfin2Samsung"

      ${lib.getExe' coreutils "mkdir"} -p "$JELLYFIN2SAMSUNG_HOME"

      ${lib.getExe' coreutils "cp"} -r "${package}/lib/samsung-jellyfin-installer/Assets" "$JELLYFIN2SAMSUNG_HOME"

      ${lib.getExe package}
    '';
  }
