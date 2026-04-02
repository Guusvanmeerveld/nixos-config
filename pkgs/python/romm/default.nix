{
  lib,
  buildPythonApplication,
  fastapi-pagination,
  zipfile-inflate64,
  python-string-similarity,
  rq-scheduler,
  fetchFromGitHub,
  setuptools,
  aiohttp,
  alembic,
  anyio,
  authlib,
  colorama,
  defusedxml,
  fastapi,
  gunicorn,
  httpx,
  itsdangerous,
  joserfc,
  opentelemetry-distro,
  opentelemetry-exporter-otlp,
  opentelemetry-instrumentation-aiohttp-client,
  opentelemetry-instrumentation-fastapi,
  # opentelemetry-instrumentation-httpx,
  opentelemetry-instrumentation-redis,
  opentelemetry-instrumentation-sqlalchemy,
  passlib,
  pillow,
  psycopg,
  pydantic,
  pydash,
  python-dotenv,
  python-magic,
  python-socketio,
  pyyaml,
  redis,
  rq,
  sentry-sdk,
  sqlalchemy,
  starlette,
  streaming-form-data,
  unidecode,
  uvicorn,
  uvicorn-worker,
  watchfiles,
  yarl,
  ipdb,
  ipykernel,
  memray,
  mypy,
  pyinstrument,
  fakeredis,
  pytest,
  pytest-asyncio,
  pytest-cov,
  pytest-env,
  pytest-mock,
  pytest-recording,
}:
buildPythonApplication (finalAttrs: {
  pname = "romm-backend";
  version = "4.8.0";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "rommapp";
    repo = "romm";
    tag = finalAttrs.version;
    hash = "sha256-Q0HGj7OSmr74lKvJs8xHbXmsmcyaGm8BLZEyvMezaV0=";
  };

  postPatch = ''
    rm -r frontend docker
    mv backend romm
  '';

  patches = [
    ./patches/0000-pyproject.patch
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    aiohttp
    alembic
    anyio
    authlib
    colorama
    defusedxml
    fastapi
    fastapi-pagination
    gunicorn
    httpx
    itsdangerous
    joserfc
    opentelemetry-distro
    opentelemetry-exporter-otlp
    opentelemetry-instrumentation-aiohttp-client
    opentelemetry-instrumentation-fastapi
    # opentelemetry-instrumentation-httpx
    opentelemetry-instrumentation-redis
    opentelemetry-instrumentation-sqlalchemy
    passlib
    pillow
    psycopg
    pydantic
    pydash
    python-dotenv
    python-magic
    python-socketio
    pyyaml
    redis
    rq
    rq-scheduler
    sentry-sdk
    sqlalchemy
    starlette
    streaming-form-data
    python-string-similarity
    unidecode
    uvicorn
    uvicorn-worker
    watchfiles
    yarl
    zipfile-inflate64
  ];

  optional-dependencies = {
    dev = [
      ipdb
      ipykernel
      memray
      mypy
      pyinstrument
    ];

    test = [
      fakeredis
      pytest
      pytest-asyncio
      pytest-cov
      pytest-env
      pytest-mock
      pytest-recording
    ];
  };

  pythonImportsCheck = [
    "romm"
  ];

  pythonRemoveDeps = ["opentelemetry-instrumentation-httpx"];

  pythonRelaxDeps = true;

  meta = {
    description = "A beautiful, powerful, self-hosted rom manager and player";
    homepage = "https://github.com/rommapp/romm";
    license = lib.licenses.agpl3Only;
    mainProgram = "romm";
  };
})
