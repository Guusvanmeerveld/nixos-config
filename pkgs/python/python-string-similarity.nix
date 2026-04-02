{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "python-string-similarity";
  version = "0.2.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "luozhouyang";
    repo = "python-string-similarity";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MMueTVLdNYpr37H7e5vc9TrGO+2bDPleH8xoSTQTUdQ=";
  };

  build-system = [
    setuptools
  ];

  pythonImportsCheck = [
    "strsimpy"
  ];

  meta = {
    description = "A library implementing different string similarity and distance measures using Python";
    homepage = "https://github.com/luozhouyang/python-string-similarity";
    license = lib.licenses.mit;
  };
})
