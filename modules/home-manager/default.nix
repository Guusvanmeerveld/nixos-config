# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  # my-module = import ./my-module.nix;
  armcord = import ./armcord.nix;
  clipmon = import ./clipmon.nix;
  mpdris2 = import ./mpdris2.nix;
  spotdl = import ./spotdl.nix;
  nwg-dock = import ./nwg-dock.nix;
  vscode-server = import ./vscode-server;
  wl-screenrec = import ./wl-screenrec.nix;
  updater = import ./updater;
}
