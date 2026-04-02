{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  crontab,
  rq,
  python-dateutil,
  ...
}:
buildPythonPackage (finalAttrs: {
  pname = "rq-scheduler";
  version = "0-unstable-2025-08-08";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "adamantike";
    repo = "rq-scheduler";
    rev = "39583cb2a00c6faa12ef34c7277893064a83c4de";
    hash = "sha256-VOgMuzSDwCIWOlWc2+dxZHXqO3IigTi0F7ZRAzbgzLE=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    crontab
    rq
    python-dateutil
  ];

  pythonRemoveDeps = ["crontab"];

  pythonImportsCheck = [
    "rq_scheduler"
  ];

  meta = {
    description = "A lightweight library that adds job scheduling capabilities to RQ (Redis Queue";
    homepage = "https://github.com/adamantike/rq-scheduler";
    changelog = "https://github.com/adamantike/rq-scheduler/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
  };
})
