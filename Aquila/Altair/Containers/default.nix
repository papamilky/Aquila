{
  inputs,
  lib,
  config,
  ...
}: let
  getSystemConfiguration = dir:
    lib.flatten (lib.mapAttrsToList (
      name: type:
        if type == "directory"
        then getSystemFiles (dir + "/${name}")
        else []
    ) (builtins.readDir dir));

  getContainers = dir:
    lib.flatten (lib.mapAttrsToList (
      name: type:
        if type == "directory"
        then getHomeFiles (dir + "/${name}")
        else []
    ) (builtins.readDir dir));

  getHomeFiles = dir:
    lib.flatten (lib.mapAttrsToList (
      name: type:
        if type == "regular" && name == "default.nix"
        then [(dir + "/${name}")]
        else []
    ) (builtins.readDir dir));

  getSystemFiles = dir:
    lib.flatten (lib.mapAttrsToList (
      name: type:
        if type == "regular" && name == "system.nix"
        then [(dir + "/${name}")]
        else []
    ) (builtins.readDir dir));

  cfg = config.aquila.system.services.podman-rootless;
in {
  imports =
    getSystemConfiguration ./.
    ++ [
      inputs.quadlet-nix.nixosModules.quadlet
    ];

  config = lib.mkIf cfg.enable {
    users.users.podman = {
      isNormalUser = true;
      description = "podman user";
      linger = true;
      autoSubUidGidRange = true;
    };

    virtualisation.containers.storage.settings.driver = "btrfs";

    networking.firewall.allowedTCPPorts = [8000 8001];
    networking.firewall.allowedUDPPorts = [8001];
    networking.nftables.enable = true;

    networking.nftables.ruleset = ''
      table ip nat {
          chain PREROUTING {
              type nat hook prerouting priority dstnat; policy accept;
              tcp dport 80 dnat to :8000
              tcp dport 443 dnat to :8001
          }

          chain OUTPUT {
              type nat hook output priority dstnat; policy accept;

              ip daddr { 127.0.0.1, 192.168.1.144 } tcp dport 80  dnat to :8000
              ip daddr { 127.0.0.1, 192.168.1.144 } tcp dport 443 dnat to :8001
          }
      }
    '';

    systemd.network.enable = true;
    systemd.network.wait-online.enable = true;
    systemd.network.wait-online.anyInterface = true;

    home-manager.users.podman = {
      pkgs,
      config,
      ...
    }: {
      # ...
      imports =
        getContainers ./.
        ++ [
          inputs.quadlet-nix.homeManagerModules.quadlet
        ];
      virtualisation.quadlet.autoEscape = true;
      # This is crucial to ensure the systemd services are (re)started on config change
      systemd.user.startServices = "sd-switch";

      programs.bash.enable = true;
      services.podman = {
        enable = true;
        autoUpdate.enable = true;
      };

      xdg.configFile."containers/registries.conf".text = ''
        [registries.insecure]
        registries = ["192.168.1.144:3001"]
      '';

      home.stateVersion = "23.11";
    };
  };
}
