{config, ...}: let
  ConfigDir = "containers/jellyfin";
  HomeDirectory = config.home.homeDirectory;

  ContainerDir = "${HomeDirectory}/${ConfigDir}";
in {
  virtualisation.quadlet = let
    inherit (config.virtualisation.quadlet) networks pods;
  in {
    containers = {
      jellyfin = {
        autoStart = true;
        serviceConfig = {
          Restart = "always";
        };
        containerConfig = {
          image = "docker.io/jellyfin/jellyfin:latest";
          userns = "keep-id:uid=1002,gid=100";
          volumes = [
            "${ContainerDir}/data:/data"
            "${ContainerDir}/config:/config"
          ];
          networks = [networks.jellyfin.ref];
        };
      };
    };

    networks = {
      jellyfin.networkConfig.subnets = ["10.0.126.1/24"];
    };
  };

  caddy = {
    networks = [config.virtualisation.quadlet.networks.jellyfin.ref];
    config = [
      ''
        jellyfin.internal {
          reverse_proxy http://jellyfin:8096
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
