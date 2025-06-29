let
  desktop = [
    ./Services/sound.nix
    ./Services/cups.nix
    ./Services/avahi.nix
    ./Services/podman.nix
    ./Services/ssh.nix
    ./Services/sops.nix
    ./Services/bluetooth.nix
    ./Services/solaar.nix
    ./Services/navidrome.nix

    ./Core

    ./Programs
  ];

  server = [
    ./Services/podman.nix
    ./Services/avahi.nix
    ./Services/ssh.nix
    ./Services/sops.nix

    ./Core

    ./Programs
  ];
in {
  inherit desktop;
  inherit server;
}
