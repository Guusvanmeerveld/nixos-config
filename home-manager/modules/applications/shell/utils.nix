{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [duf gdu];
  };
}
