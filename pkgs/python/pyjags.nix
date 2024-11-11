{ pkgs }: pkgs.python311.pkgs.buildPythonPackage
    rec {
    pname = "pyjags";
    version = "1.3.8";
    format = "pyproject";

    nativeBuildInputs = with pkgs; [
        python311.pkgs.flit-core
        pkg-config
    ];

    propagatedBuildInputs = with pkgs.python311.pkgs;
        [
        setuptools
        numpy
        pybind11
        arviz
        deepdish
        ] ++ (with pkgs; [
        jags
        ]);

    src = pkgs.fetchFromGitHub {
        owner = "michaelnowotny";
        repo = "pyjags";
        rev = "9fc67d2b9d17b629a05ce2edc79567802a95aa1f";
        hash = "sha256-LkNUs13feb6p1NZ7Cucy0UDS9VjSP2ytw1G1bKwystI=";
    };
}