{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  fastapi,
  pydantic,
  typing-extensions,
  aiosqlite,
  asyncpg,
  sqlalchemy,
  # databases,
  # django,
  # elasticsearch-dsl,
  # google-cloud-firestore,
  # mongoengine,
  # motor,
  # odmantic,
  # orm,
  # ormar,
  # piccolo,
  # psycopg,
  # scylla-driver,
  # sqlakeyset,
  # sqlmodel,
  # tortoise-orm,
  ...
}:
buildPythonPackage (finalAttrs: {
  pname = "fastapi-pagination";
  version = "0.15.11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "uriyyo";
    repo = "fastapi-pagination";
    tag = finalAttrs.version;
    hash = "sha256-Ec0se1UdJxtwkaaz044CE6ZGNHGkT847fuDNoMkQlk0=";
  };

  build-system = [
    hatchling
  ];

  dependencies = [
    fastapi
    pydantic
    typing-extensions
  ];

  optional-dependencies = {
    aiosqlite = [
      aiosqlite
    ];
    asyncpg = [
      asyncpg
      sqlalchemy
    ];
  };

  pythonImportsCheck = [
    "fastapi_pagination"
  ];

  meta = {
    description = "FastAPI pagination";
    homepage = "https://github.com/uriyyo/fastapi-pagination";
    license = lib.licenses.mit;
  };
})
