{
  buildNpmPackage,
  fetchFromGitHub,
  jq,
  lib,
  ...
}:
buildNpmPackage (let
  binName = "free-epic-games";
in {
  pname = "free-epic-games";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "claabs";
    repo = "epicgames-freegames-node";
    rev = "0a44b5b6f6dac797e7cb23d73087110b0e96d15b";
    hash = "sha256-dNDxaGPNEu9pSG2u1xCm7/FP0XtYoPmVSs7BjGrZgOI=";
  };

  npmDepsHash = "sha256-CSFKckhPf2S5SRfGRBMBPHm0mfSwE1onRzf5lUoGguA=";

  postPatch = ''
    mv package.json 2.json
    ${lib.getExe jq} '. + {"bin":{"${binName}":"dist/src/index.js"}}' -rS 2.json > package.json
  '';

  env = {
    PUPPETEER_SKIP_DOWNLOAD = true;
  };

  meta = {
    description = "Automatically login and find available free games the Epic Games Store. Sends you a prepopulated checkout link so you can complete the checkout after logging in. Supports multiple accounts, login sessions, and scheduled runs. ";
    homepage = "https://github.com/claabs/epicgames-freegames-node";
    mainProgram = binName;
    license = lib.licenses.mit;
  };
})
