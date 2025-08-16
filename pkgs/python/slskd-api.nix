{pkgs}:
pkgs.python3.pkgs.buildPythonPackage
rec {
  pname = "slskd-api";
  version = "0.1.5";

  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "bigoulours";
    repo = "slskd-python-api";
    rev = "v${version}";
    hash = "sha256-Kyzbd8y92VFzjIp9xVbhkK9rHA/6KCCJh7kNS/MtixI=";
  };

  build-system = with pkgs.python3.pkgs; [setuptools setuptools-git-versioning];

  propagatedBuildInputs = with pkgs.python3.pkgs; [
    requests
  ];
}
