{ ...
}: {
  services.xserver = {
    deviceSection = ''
      Option "TearFree" "true"
      Option "VariableRefresh" "true"
    '';

    videoDrivers = [ "amdgpu" ];
  };

  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware.opengl.driSupport = true;
  # For 32 bit applications
  hardware.opengl.driSupport32Bit = true;

}
