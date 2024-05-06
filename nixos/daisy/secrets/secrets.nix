let
  daisy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK6X2d/xZs8K+ZoR3JqE8bub2b1nxrxu94Qylg/8fNrp root@daisy";
in {
  "jupyter.age".publicKeys = [daisy];
}