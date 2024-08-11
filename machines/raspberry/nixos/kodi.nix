{pkgs, ...}:
let 
  kodi = pkgs.kodi.passthru.withPackages (kodiPkgs: with kodiPkgs; [
    jellyfin
    netflix
    keymap
  ]);
in
{
  config = {
    users.extraUsers.kodi = {
      isNormalUser = true;
      extraGroups = ["video" "input" "audio"];
    };

    services.xserver = {
      enable = true;

      desktopManager = {
        kodi.enable = true;
        kodi.package = kodi;
      };

      displayManager = {
        autoLogin.enable = true;
        autoLogin.user = "kodi";
      };
    };

    # Wayland
    # Wayland is currently only able to operate on one resolution which is not desired.
    # services = {
    #    cage = let 
    #    program = pkgs.writeShellScript "start-kodi" ''
    #        ${pkgs.wlr-randr}/bin/wlr-randr --output HDMI-A-1 --mode 3840x2160@30
    #        ${kodi}/bin/kodi-standalone
    #    ''; in {
    #        inherit program;
    #
    #        enable = true;
    #
    #        user = "kodi";
    #    };
    # };
  };
}