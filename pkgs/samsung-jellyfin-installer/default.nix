{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  coreutils,
  writeScript,
  buildFHSEnv,
}: let
  package = buildDotnetModule (finalAttrs: {
    pname = "Apps2Samsung";
    version = "2.5.6";

    src = fetchFromGitHub {
      owner = "Apps2Samsung";
      repo = "Apps2Samsung";
      tag = "v${finalAttrs.version}";
      hash = "sha256-fD66Rx/OV7VAcIRJtUiIJ7JjYuERTMtRFMBy2uytZhM=";
    };

    postPatch = ''
      find Jellyfin2Samsung-CrossOS -type f -name "*.cs" -exec sed -i 's|AppContext.BaseDirectory|Environment.GetEnvironmentVariable("JELLYFIN2SAMSUNG_HOME")|g' {} +
    '';

    projectFile = [
      "Jellyfin2Samsung-CrossOS/Apps2Samsung.csproj"
    ];

    executables = ["Apps2Samsung"];

    nugetDeps = ./deps.json;

    meta = {
      description = "One-click install of Jellyfin on your Samsung TV - fully compatible with all Tizen versions";
      homepage = "https://github.com/Jellyfin2Samsung/Samsung-Jellyfin-Installer";
      license = lib.licenses.mit;
      # maintainers = with lib.maintainers; [];
      mainProgram = "Apps2Samsung";
      platforms = lib.platforms.all;
    };
  });
in
  buildFHSEnv {
    # Wrap in FHS env because program downloads a Tizen CLI tool which cannot natively be run in NixOS, but it essential to the functionality of the program.
    name = "apps2samsung";

    inherit (package) fetch-deps;

    targetPkgs = pkgs: (with pkgs; [
      zlib
      openssl
    ]);

    runScript = writeScript "start-apps2samsung" ''
      export JELLYFIN2SAMSUNG_HOME="$HOME/.config/Apps2Samsung"

      ${lib.getExe' coreutils "mkdir"} -p "$JELLYFIN2SAMSUNG_HOME"

      ${lib.getExe' coreutils "cp"} -r "${package}/lib/Apps2Samsung/Assets" "$JELLYFIN2SAMSUNG_HOME"

      ${lib.getExe package}
    '';
  }
