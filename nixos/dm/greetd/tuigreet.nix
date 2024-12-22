{
  lib,
  pkgs,
  ...
}: {
  executable = {cmd}: "${lib.getExe pkgs.greetd.tuigreet} --time --remember --cmd ${cmd}";
}
