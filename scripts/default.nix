{pkgs, ...}: let
  inherit (pkgs) lib;
in {
  manage-secrets = pkgs.writeShellApplication {
    name = "manage-secrets";

    text = builtins.readFile ./manage-secrets.sh;
  };

  swayFocusOrStart = app_id: path: let
    scriptPackage = pkgs.writeShellApplication {
      name = "sway-focus-or-start-${app_id}";

      runtimeInputs = with pkgs; [procps];

      # If we cannot focus the window, start it.
      text = ''
        if ! swaymsg [app_id="${app_id}"] focus; then
          exec ${path};
        fi
      '';
    };
  in "exec --no-startup-id ${lib.getExe scriptPackage}";
}
