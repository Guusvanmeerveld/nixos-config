# Initially copied from: https://github.com/IdanReed/BasicBastardSelfhosted/blob/main/nixos-de/pkgs/openconnect-saml.nix
{
  lib,
  python3Packages,
  fetchFromGitHub,
  openconnect,
  qt6,
  libfido2,
}:
python3Packages.buildPythonApplication rec {
  pname = "openconnect-saml";
  version = "0.24.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mschabhuettl";
    repo = "openconnect-saml";
    tag = "v${version}";
    hash = "sha256-4efr1EyewHzaaCZ2bRg22W1lqq/PlaccbQWG7ZA9bTM=";
  };

  build-system = [python3Packages.hatchling];

  dependencies = with python3Packages; [
    attrs
    colorama
    keyring
    lxml
    prompt-toolkit
    pyotp
    pysocks
    pyxdg
    requests
    structlog
    toml
    pyqt6
    pyqt6-webengine
  ];

  nativeBuildInputs = [qt6.wrapQtAppsHook];
  buildInputs = [qt6.qtbase];
  dontWrapQtApps = true;
  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [openconnect]}"
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [libfido2]}"
  ];

  doCheck = false;
  pythonImportsCheck = [];

  meta = {
    description = "OpenConnect wrapper adding Cisco SAML/SSO (Azure AD, Okta) authentication";
    homepage = "https://github.com/mschabhuettl/openconnect-saml";
    license = lib.licenses.gpl3Plus;
    mainProgram = "openconnect-saml";
    platforms = lib.platforms.linux;
  };
}
