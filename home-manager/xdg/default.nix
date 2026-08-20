{
  imports = [./portals];

  config = {
    xdg.userDirs = {
      enable = true;
      setSessionVariables = true;
    };
  };
}
