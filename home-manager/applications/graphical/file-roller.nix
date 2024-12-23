{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.file-roller;

  desktopFile = "org.gnome.FileRoller.desktop";

  openByDefault = [
    "application/bzip2"
    "application/gzip"
    "application/vnd.android.package-archive"
    "application/vnd.ms-cab-compressed"
    "application/vnd.debian.binary-package"
    "application/vnd.rar"
    "application/x-7z-compressed"
    "application/x-7z-compressed-tar"
    "application/x-ace"
    "application/x-alz"
    "application/x-apple-diskimage"
    "application/x-ar"
    "application/x-archive"
    "application/x-arj"
    "application/x-brotli"
    "application/x-bzip-brotli-tar"
    "application/x-bzip"
    "application/x-bzip-compressed-tar"
    "application/x-bzip1"
    "application/x-bzip1-compressed-tar"
    "application/x-cabinet"
    "application/x-cd-image"
    "application/x-compress"
    "application/x-compressed-tar"
    "application/x-cpio"
    "application/x-chrome-extension"
    "application/x-deb"
    "application/x-ear"
    "application/x-ms-dos-executable"
    "application/x-gtar"
    "application/x-gzip"
    "application/x-gzpostscript"
    "application/x-java-archive"
    "application/x-lha"
    "application/x-lhz"
    "application/x-lrzip"
    "application/x-lrzip-compressed-tar"
    "application/x-lz4"
    "application/x-lzip"
    "application/x-lzip-compressed-tar"
    "application/x-lzma"
    "application/x-lzma-compressed-tar"
    "application/x-lzop"
    "application/x-lz4-compressed-tar"
    "application/x-ms-wim"
    "application/x-rar"
    "application/x-rar-compressed"
    "application/x-rpm"
    "application/x-source-rpm"
    "application/x-rzip"
    "application/x-rzip-compressed-tar"
    "application/x-tar"
    "application/x-tarz"
    "application/x-tzo"
    "application/x-stuffit"
    "application/x-war"
    "application/x-xar"
    "application/x-xz"
    "application/x-xz-compressed-tar"
    "application/x-zip"
    "application/x-zip-compressed"
    "application/x-zstd-compressed-tar"
    "application/x-zoo"
    "application/zip"
    "application/zstd"
  ];
in {
  options = {
    custom.applications.graphical.file-roller = {
      enable = lib.mkEnableOption "Enable File roller archive manager";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.mimeApps.defaultApplications = builtins.listToAttrs (map (mimeType: {
        name = mimeType;
        value = desktopFile;
      })
      openByDefault);

    home.packages = with pkgs; [file-roller];
  };
}
