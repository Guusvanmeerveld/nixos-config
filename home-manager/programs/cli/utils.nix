{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [duf gdu yt-dlp nmap];
  };
}
