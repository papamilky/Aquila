{
  config,
  sops,
  inputs,
  lib,
  self,
  ...
}: {
  sops.age.sshKeyPaths = [
    "/etc/ssh/ssh_host_ed25519_key" # All Hosts Should Have SSH Keys
  ];

  sops.defaultSopsFile = "${self}/Secrets/Secrets.yaml";
}
