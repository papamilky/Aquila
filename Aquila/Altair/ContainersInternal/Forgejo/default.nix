{config, ...}: let
  ContainerDir = "/mount/Vega/forgejo";
in {
  virtualisation.quadlet = let
    inherit (config.virtualisation.quadlet) networks pods;
  in {
    containers = {
      forgejo = {
        autoStart = true;
        serviceConfig = {
          Restart = "always";
        };
        containerConfig = {
          image = "codeberg.org/forgejo/forgejo:10-rootless";
          userns = "keep-id:uid=1002,gid=100";
          volumes = [
            "${ContainerDir}/data:/var/lib/gitea"
            "${ContainerDir}/conf:/etc/gitea"
          ];
          publishPorts = [
            "3001:3000"
          ];
          networks = ["podman" networks.forgejo.ref];
        };
      };
    };

    networks = {
      forgejo.networkConfig.subnets = ["10.0.124.1/24"];
    };
  };

  caddy = {
    networks = [config.virtualisation.quadlet.networks.forgejo.ref];
    config = [
      ''
        forgejo.internal {
          reverse_proxy forgejo:3000
          tls {
            issuer internal {
              ca Caddy
            }
          }
        }
      ''
    ];
  };
}
