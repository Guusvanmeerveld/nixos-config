{
  lib,
  stdenv,
  fetchFromGitea,
  wrapQtAppsHook,
  autoconf,
  boost,
  catch2_3,
  cmake,
  cpp-jwt,
  cubeb,
  discord-rpc,
  enet,
  ffmpeg-headless,
  fmt,
  glslang,
  libopus,
  libusb1,
  libva,
  lz4,
  nlohmann_json,
  nv-codec-headers-12,
  nx_tzdb,
  pkg-config,
  qtbase,
  qtmultimedia,
  qttools,
  qtwayland,
  qtwebengine,
  SDL2,
  sndio,
  vulkan-headers,
  vulkan-loader,
  yasm,
  zlib,
  zstd,
  libtool,
  ...
}:
stdenv.mkDerivation rec {
  pname = "sudachi";
  version = "1.0.13";

  src = fetchFromGitea {
    owner = "bigjuan";
    repo = "sudachi";
    domain = "codeberg.org";
    rev = "7baceee4eb915a6ad842066f3f99bd4dd88bbc21";
    sha256 = "sha256-vyPhOA/fe7YOVLBxQECjMb5LOAIQijBEELmdxwQb0lE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    glslang
    pkg-config
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    # vulkan-headers must come first, so the older propagated versions
    # don't get picked up by accident
    vulkan-headers

    boost
    catch2_3
    cpp-jwt
    cubeb
    discord-rpc
    # intentionally omitted: dynarmic - prefer vendored version for compatibility
    enet

    # ffmpeg deps (also includes vendored)
    # we do not use internal ffmpeg because cuda errors
    autoconf
    yasm
    libva # for accelerated video decode on non-nvidia
    nv-codec-headers-12 # for accelerated video decode on nvidia
    ffmpeg-headless
    # end ffmpeg deps

    fmt
    # intentionally omitted: gamemode - loaded dynamically at runtime
    # intentionally omitted: httplib - upstream requires an older version than what we have
    libopus
    libusb1
    # intentionally omitted: LLVM - heavy, only used for stack traces in the debugger
    lz4
    nlohmann_json
    qtbase
    qtmultimedia
    qtwayland
    qtwebengine
    # intentionally omitted: renderdoc - heavy, developer only
    SDL2
    sndio
    # not packaged in nixpkgs: simpleini
    # intentionally omitted: stb - header only libraries, vendor uses git snapshot
    # not packaged in nixpkgs: vulkan-memory-allocator
    # intentionally omitted: xbyak - prefer vendored version for compatibility
    zlib
    zstd

    libtool
  ];

  # This changes `ir/opt` to `ir/var/empty` in `externals/dynarmic/src/dynarmic/CMakeLists.txt`
  # making the build fail, as that path does not exist
  dontFixCmake = true;

  enableParallelBuilding = false;

  cmakeFlags = [
    # actually has a noticeable performance impact
    "-DSUDACHI_ENABLE_LTO=ON"

    # build with qt6
    "-DENABLE_QT6=ON"
    "-DENABLE_QT_TRANSLATION=ON"

    # use system libraries
    # NB: "external" here means "from the externals/ directory in the source",
    # so "off" means "use system"
    "-DSUDACHI_USE_EXTERNAL_SDL2=OFF"
    "-DSUDACHI_USE_EXTERNAL_VULKAN_HEADERS=OFF"

    # # don't use system ffmpeg, SUDACHI uses internal APIs
    # "-DSUDACHI_USE_BUNDLED_FFMPEG=ON"

    # don't check for missing submodules
    "-DSUDACHI_CHECK_SUBMODULES=OFF"

    # enable some optional features
    "-DSUDACHI_USE_QT_WEB_ENGINE=ON"
    "-DSUDACHI_USE_QT_MULTIMEDIA=ON"
    "-DUSE_DISCORD_PRESENCE=ON"

    # We dont want to bother upstream with potentially outdated compat reports
    "-DSUDACHI_ENABLE_COMPATIBILITY_REPORTING=OFF"
    "-DENABLE_COMPATIBILITY_LIST_DOWNLOAD=OFF" # We provide this deterministically

    "-DSUDACHI_TESTS=OFF"
  ];

  # Does some handrolled SIMD
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isx86_64 "-msse4.1";

  # Fixes vulkan detection.
  # FIXME: patchelf --add-rpath corrupts the binary for some reason, investigate
  qtWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${vulkan-loader}/lib"
  ];

  preConfigure = ''
    # see https://github.com/NixOS/nixpkgs/issues/114044, setting this through cmakeFlags does not work.
    cmakeFlagsArray+=(
      "-DTITLE_BAR_FORMAT_IDLE=${pname} | ${version} (nixpkgs) {}"
      "-DTITLE_BAR_FORMAT_RUNNING=${pname} | ${version} (nixpkgs) | {}"
    )

    # provide pre-downloaded tz data
    mkdir -p build/externals/nx_tzdb
    ln -s ${nx_tzdb} build/externals/nx_tzdb/nx_tzdb
  '';

  # postConfigure = ''
  #   ln -sf ${compat-list} ./dist/compatibility_list/compatibility_list.json
  # '';

  postInstall = "
    install -Dm444 $src/dist/72-sudachi-input.rules $out/lib/udev/rules.d/72-sudachi-input.rules
  ";

  # passthru.updateScript = nix-update-script {
  #   extraArgs = ["--version-regex" "mainline-0-(.*)"];
  # };

  meta = with lib; {
    homepage = "https://sudachi.emuplace.app/";
    description = "Nintendo Switch emulation without the iffy bits and support for more games";
    mainProgram = "sudachi";
    platforms = ["aarch64-linux" "x86_64-linux"];
    license = with licenses; [
      mit
    ];
  };
}
