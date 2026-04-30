{
  lib,
  fetchFromGitHub,
  bun2nix,
  runCommandLocal,
  ...
}:
bun2nix.writeBunApplication rec {
  pname = "degoog";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "fccview";
    repo = "degoog";
    tag = version;
    hash = "sha256-Svez9TM5EUaoppZqKwu0Xg9VOTJrGC34jL2kj9sFkek=";
  };

  buildPhase = ''
    bun run build
  '';

  startScript = ''
    bun run start
  '';

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = runCommandLocal "fetch-degoog-deps" {} ''
      ${lib.getExe bun2nix} --lock-file ${src}/bun.lock --output-file $out
    '';
  };

  meta = {
    description = "Search engine aggregator with a comprehensive plugin/extension system";
    homepage = "https://fccview.github.io/degoog/";
    license = lib.licenses.mit;
  };
}
