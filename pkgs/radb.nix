{pkgs}:
pkgs.python3Packages.buildPythonApplication rec {
  pname = "radb";
  version = "3.0.5";

  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "junyang";
    repo = pname;
    rev = "108525d79e02454c2b722485f6345163e60b7cf1";
    hash = "sha256-lkHuQfMOkaPB63SSsDdXYfciD4dR27a6tXWqrpnCC/Q=";
  };

  build-system = with pkgs; [
    python3Packages.setuptools
  ];

  dependencies = with pkgs.python3Packages; [
    sqlalchemy
    antlr4-python3-runtime
  ];

  meta = {
    description = "RA (radb): A relational algebra interpreter over relational databases ";
    homepage = "https://github.com/junyang/radb";
    maintainers = [];

    mainProgram = "radb";
  };
}
