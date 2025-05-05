{config, ...}: let
  ContainerDir = "Music";

  RootDir = "/mount/Rigel";

  NaviDir = "${ContainerDir}/Navi";
  LidarrDir = "${ContainerDir}/Lidarr";
  slskdDir = "${ContainerDir}/slskd";
  SoularrDir = "${ContainerDir}/Soularr";
in {
  virtualisation.quadlet = let
    inherit (config.virtualisation.quadlet) networks pods;
  in {
    containers = {
      Lidarr = {
        autoStart = true;
        serviceConfig = {
          RestartSec = "15";
          Restart = "always";
        };
        containerConfig = {
          image = "ghcr.io/linuxserver-labs/prarr:lidarr-plugins";

          volumes = [
            "${RootDir}/${LidarrDir}/config:/config"
            "${RootDir}/${ContainerDir}/data:/data"
          ];

          environments = {
            PUID = "0";
            PGID = "0";
          };

          pod = pods.Music.ref;
          networks = ["podman" networks.Music.ref];
        };
      };

      slskd = {
        autoStart = true;
        serviceConfig = {
          RestartSec = "15";
          Restart = "always";
        };
        containerConfig = {
          image = "slskd/slskd:latest";
          userns = "keep-id:uid=1002,gid=100";
          user = "1002:100";

          volumes = [
            "${RootDir}/${slskdDir}/config:/app"
            "${RootDir}/${ContainerDir}/data:/data"
          ];

          publishPorts = [
            "50300:50300"
          ];

          environments = {
            SLSKD_REMOTE_CONFIGURATION = "true";
            SLSKD_SHARED_DIR = "/data/music";
          };

          pod = pods.Music.ref;
          networks = ["podman" networks.Music.ref];
        };
      };

      Navidrome = {
        autoStart = true;
        serviceConfig = {
          RestartSec = "15";
          Restart = "always";
        };
        containerConfig = {
          image = "deluan/navidrome:latest";
          userns = "keep-id:uid=1002,gid=100";

          volumes = [
            "${RootDir}/${NaviDir}/config:/data"
            "${RootDir}/${ContainerDir}/data/music:/music:ro"
          ];
          environments = {
            ######
          };

          pod = pods.Music.ref;
          networks = ["podman" networks.Music.ref];
        };
      };
    };

    networks = {
      Music.networkConfig.subnets = ["10.0.128.1/24"];
    };

    pods = {
      Music = {};
    };
  };

  caddy = {
    networks = [config.virtualisation.quadlet.networks.Music.ref];
    config = [
      ''
        navi.internal {
          reverse_proxy navidrome:4533
          tls {
            issuer internal {
              ca Caddy
            }
          }
        }

        lidarr.internal {
          reverse_proxy lidarr:8686
          tls {
            issuer internal {
              ca Caddy
            }
          }
        }

        slskd.internal {
          reverse_proxy slskd:5030
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
