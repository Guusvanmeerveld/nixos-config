{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkOption
    types
    literalExpression
    mkIf
    getExe
    mergeAttrsList
    nameValuePair
    mapAttrs'
    replaceStrings
    optionalString
    ;

  iniFormat = pkgs.formats.ini {};

  defaultSettings = {
    Preferences = {
      # If a theme is specified, enable alternative web ui.
      "WebUI\\AlternativeUIEnabled" = toString (cfg.theme != null);
      # If specified theme is "vuetorrent", link to their files.
      "WebUI\\RootFolder" = optionalString (cfg.theme == "vuetorrent") "${pkgs.vuetorrent}/share/vuetorrent";
    };

    BitTorrent = {
      "Session\\DefaultSavePath" = cfg.saveDir;
    };
  };

  settingsCombined = mergeAttrsList [
    cfg.settings
    defaultSettings
  ];

  settingsFile = iniFormat.generate "qbittorrent-settings" (mapAttrs' (
      name: value:
        nameValuePair
        # Replace spaces in keys with backslashes
        (replaceStrings [" "] ["\\"] name)
        value
    )
    settingsCombined);

  cfg = config.services.qbittorrent;
  UID = 888;
  GID = 888;
in {
  options.services.qbittorrent = {
    enable = mkEnableOption "Enable headless qBittorrent service";

    user = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = ''
        User account under which qBittorrent runs.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = ''
        Group under which qBittorrent runs.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Open services.qBittorrent.port to the outside network.
      '';
    };

    webUIPort = mkOption {
      type = types.port;
      default = 4545;
      description = ''
        qBittorrent web UI port.
      '';
    };

    torrentPort = mkOption {
      type = types.port;
      default = 6881;
      description = ''
        qBittorrent torrenting port.
      '';
    };

    confirmLegalNotice = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to suppress the legal notice when qBittorrent starts up";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/qbittorrent";
      description = ''
        The directory where qBittorrent stores its data files.
      '';
    };

    saveDir = mkOption {
      type = types.path;
      default = "/var/lib/qbittorrent/downloads";
      description = ''
        The directory where qBittorrent stores its data files.
      '';
    };

    theme = mkOption {
      type = with types; nullOr (enum ["vuetorrent"]);
      default = null;
      description = "The theme to use";
    };

    settings = mkOption {
      inherit (iniFormat) type;
      description = "Configure qBittorrent settings";
      default = {};
    };

    package = mkOption {
      type = types.package;
      default = pkgs.qbittorrent-nox;
      defaultText = literalExpression "pkgs.qbittorrent-nox";
      description = ''
        The qbittorrent package to use.
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.webUIPort];
      allowedUDPPorts = [cfg.torrentPort];
    };

    environment.systemPackages = [cfg.package];

    systemd.services.qbittorrent = {
      # based on the plex.nix service module and
      # https://github.com/qbittorrent/qBittorrent/blob/master/dist/unix/systemd/qbittorrent-nox%40.service.in
      description = "qBittorrent-nox service";
      documentation = ["man:qbittorrent-nox(1)"];
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;

        # Run the pre-start script with full permissions (the "!" prefix) so it
        # can create the data directory if necessary.
        ExecStartPre = let
          configDir = "${cfg.dataDir}/qBittorrent/config";
          configFile = "${configDir}/qBittorrent.conf";

          crudini = lib.getExe pkgs.crudini;

          preStartScript = pkgs.writeShellScript "qbittorrent-pre-start" ''
            # Create config directory if it doesn't exist
            if ! test -d "${configDir}"; then
              echo "Creating initial qBittorrent config directory in: ${configDir}"

              mkdir ${configDir} -p

              chmod 0755 ${cfg.dataDir} -R

              chown ${cfg.user}:${cfg.group} ${cfg.dataDir} -R
            fi

            if ! test -f "${configFile}"; then
              echo "Creating initial qBittorrent config file"

              install -D -m 0755 -o "${cfg.user}" -g "${cfg.group}" "${toString settingsFile}" "${configFile}"
            fi

            # Override settings with settings specified by Nix.
            # Any settings not specified by Nix will be untouched.
            ${crudini} --merge ${configFile} < ${toString settingsFile}
          '';
        in "!${preStartScript}";

        ExecStart = getExe cfg.package;
      };

      environment = {
        QBT_PROFILE = cfg.dataDir;
        QBT_WEBUI_PORT = toString cfg.webUIPort;
        QBT_CONFIRM_LEGAL_NOTICE = toString cfg.confirmLegalNotice;
      };
    };

    users.users = mkIf (cfg.user == "qbittorrent") {
      qbittorrent = {
        inherit (cfg) group;
        uid = UID;
      };
    };

    users.groups = mkIf (cfg.group == "qbittorrent") {
      qbittorrent = {gid = GID;};
    };
  };
}
