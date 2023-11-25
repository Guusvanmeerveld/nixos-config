{ ... }: {
  xsession.windowManager.i3.config.workspaceOutputAssign = [
    {
      output = "DisplayPort-1";
      workspace = "1: messaging";
    }
    {
      output = "DisplayPort-1";
      workspace = "2: music";
    }
  ];

}
