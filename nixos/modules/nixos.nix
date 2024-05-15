{...}: {
  config = {
    nix = {
      settings = {
        experimental-features = ["nix-command" "flakes"];
        auto-optimise-store = true;
        warn-dirty = false;
      };

      gc = {
        automatic = true;
        options = "--delete-older-than 30d";
        dates = "weekly";
      };
    };
  };
}
