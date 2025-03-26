{config, ...}: let
  ConfigDir = "containers/vaultwarden";
  HomeDirectory = config.home.homeDirectory;

  ContainerDir = "${HomeDirectory}/${ConfigDir}";
in {
  virtualisation.quadlet = let
    inherit (config.virtualisation.quadlet) networks pods;
  in {
    containers = {
      vaultwarden = {
        autoStart = true;
        serviceConfig = {
          Restart = "always";
        };
        containerConfig = {
          image = "ghcr.io/dani-garcia/vaultwarden:latest";
          userns = "keep-id:uid=1002,gid=100";
          volumes = [
            "${ContainerDir}:/data"
          ];
          environments = {
            ROCKET_PORT = "8080";
            DOMAIN = "https://vaultwarden.internal/";
          };
          networks = [networks.vaultwarden.ref];
        };
      };
    };

    networks = {
      vaultwarden.networkConfig.subnets = ["10.0.125.1/24"];
    };
  };

  caddy = {
    networks = [config.virtualisation.quadlet.networks.vaultwarden.ref];
    config = [
      ''
        vaultwarden.internal {
          reverse_proxy http://vaultwarden:8080
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
