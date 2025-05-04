{lib, ...}: {
  advancedUserEnabled = true;
  hiddenSettings = {};

  dynamicFilteringString = let
    inherit (lib) concatStrings concatStringsSep;

    allowedThirdParties = ["githubassets.com"];
  in
    concatStrings [
      ''
        behind-the-scene * * noop
        behind-the-scene * inline-script noop
        behind-the-scene * 1p-script noop
        behind-the-scene * 3p-script noop
        behind-the-scene * 3p-frame noop
        behind-the-scene * image noop
        behind-the-scene * 3p noop
      ''

      # Block third party content on websites
      ''
        * * 3p-script block
        * * 3p-frame block
      ''

      # Allow some third parties
      (concatStringsSep "\n" (map (thirdParty: "* ${thirdParty} * noop") allowedThirdParties))
    ];

  selectedFilterLists = [
    "ublock-filters"
    "ublock-badware"
    "ublock-privacy"
    "ublock-unbreak"
    "ublock-quick-fixes"

    "easylist"
    "easyprivacy"

    "easylist-chat"
    "easylist-newsletters"
    "easylist-notifications"
    "easylist-annoyances"
    "ublock-annoyances"

    "urlhaus-1"
    "curben-phishing"

    "plowe-0"

    "fanboy-social"
    "adguard-social"
    "fanboy-thirdparty_social"
  ];
}
