{
  fetchFromGitea,
  buildPythonPackage,
  setuptools,
  setuptools-scm,
  wheel,
  inflate64,
  check-manifest,
  flake8,
  # flake8-black,
  flake8-deprecated,
  isort,
  mypy,
  mypy-extensions,
  pygments,
  readme-renderer,
  twine,
  docutils,
  sphinx,
}:
buildPythonPackage (finalAttrs: {
  pname = "zipfile-inflate64";
  version = "0.2";
  pyproject = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "miurahr";
    repo = "zipfile-inflate64";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vlVSshOWX4HWoqGdc0tvyzSxDtdAUvoLetz5VEncVMA=";
  };

  build-system = [
    setuptools
    setuptools-scm
    wheel
  ];

  dependencies = [
    inflate64
  ];

  optional-dependencies = {
    check = [
      check-manifest
      flake8
      flake8-deprecated
      isort
      mypy
      mypy-extensions
      pygments
      readme-renderer
      twine
    ];

    docs = [
      docutils
      sphinx
    ];
  };

  pythonImportsCheck = [
    "zipfile_inflate64"
  ];

  meta = {
    description = "Extract Enhanced Deflate ZIP archives with Python's zipfile API";
    homepage = "https://codeberg.org/miurahr/zipfile-inflate64";
  };
})
