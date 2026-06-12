{
  lib,
  fetchFromGitHub,
  bun2nix,
  runCommandLocal,
  ...
}:
bun2nix.writeBunApplication rec {
  pname = "degoog";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "degoog-org";
    repo = "degoog";
    tag = version;
    hash = "sha256-99DPnZcjhqGn4HdmufGzgkEKWYhXXwe5R8it0QS0qLY=";
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
