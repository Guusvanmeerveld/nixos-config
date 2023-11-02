{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName  = "Guus van Meerveld";
    userEmail = "mail@guusvanmeerveld.dev";
  };
}