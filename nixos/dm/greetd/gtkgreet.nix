{
  lib,
  pkgs,
  ...
}: {
  executable = "${lib.getExe pkgs.greetd.gtkgreet} -l";
}
