{config, ...}: let
  ContainerDir = "containers/Minecraft";

  HomeDirectory = config.home.homeDirectory;

  ProxyDir = "${ContainerDir}/Proxy121";
  LobbyDir = "${ContainerDir}/Lobby121";
  CreativeDir = "${ContainerDir}/Creative121";
in {
  virtualisation.quadlet = let
    inherit (config.virtualisation.quadlet) networks pods;
  in {
    containers = {
      Creative121 = {
        autoStart = true;
        serviceConfig = {
          RestartSec = "15";
          Restart = "always";
        };
        containerConfig = {
          image = "192.168.1.144:3001/papamilky/minecraft-container-image:latest";
          userns = "keep-id:uid=1002,gid=100";

          volumes = ["${HomeDirectory}/${CreativeDir}:/data"];
          environments = {
            EULA = "TRUE";
            INIT_MEMORY = "512M";
            MAX_MEMORY = "6G";
            VIEW_DISTANCE = "24";
            TYPE = "FABRIC";
            VERSION = "1.21";
            MODRINTH_PROJECTS = "fabric-api,lithium,autoshutdown,axiom,c2me-fabric,fabricproxy-lite,krypton,nullscape,spark,worldedit,worldweaver,wwoo,immediatelyfast,ferrite-core,cristel-lib,viaversion,viabackwards,viafabric";
            MODRINTH_ALLOWED_VERSION_TYPE = "alpha";

            FETCH_RESPONSE_TIMEOUT = "PT20S";
          };

          pod = pods.minecraft121.ref;
          networks = ["podman" networks.minecraft121.ref];
        };
      };

      Lobby121 = {
        autoStart = true;
        serviceConfig = {
          RestartSec = "10";
          Restart = "always";
        };
        containerConfig = {
          image = "docker.io/itzg/minecraft-server:latest";
          userns = "keep-id:uid=1002,gid=100";

          volumes = ["${HomeDirectory}/${LobbyDir}:/data"];
          environments = {
            EULA = "TRUE";
            INIT_MEMORY = "512M";
            MAX_MEMORY = "2G";
            VIEW_DISTANCE = "4";
            TYPE = "PURPUR";
            VERSION = "1.21";
            MOTD = "The Creative Replacement";
            MODRINTH_PROJECTS = "itemjoin,executableitems,zmenu,score";
            MODRINTH_ALLOWED_VERSION_TYPE = "alpha";
            SPIGET_RESOURCES = "34315,6245,28140";
          };

          pod = pods.minecraft121.ref;
          networks = ["podman" networks.minecraft121.ref];
        };
      };

      Proxy121 = {
        autoStart = true;
        serviceConfig = {
          RestartSec = "10";
          Restart = "always";
        };
        containerConfig = {
          image = "docker.io/itzg/mc-proxy:latest";
          userns = "keep-id:uid=1002,gid=100";

          volumes = ["${HomeDirectory}/${ProxyDir}:/server"];

          environments = {
            TYPE = "VELOCITY";
            MINECRAFT_VERSION = "1.21";
            INIT_MEMORY = "100M";
            MAX_MEMORY = "512M";
            CFG_MOTD = "Formerly The Creative Joint";
            REPLACE_ENV_VARIABLES = "true";
            ICON = "https://cdn.discordapp.com/attachments/1110541249057927191/1349263297823772715/qNHnExZ.png?ex=67d276de&is=67d1255e&hm=fb8b00e2f16cddac9a17022e1f1941d7075a57db78846fad7183445a8612ff46&";
            MODRINTH_PROJECTS = "autoserver,viaversion,viabackwards";
            MODRINTH_ALLOWED_VERSION_TYPE = "alpha";
          };

          publishPorts = ["25565:25577"];

          pod = pods.minecraft121.ref;
          networks = ["podman" networks.minecraft121.ref];
        };
      };
    };

    networks = {
      minecraft121.networkConfig.subnets = ["10.0.123.1/24"];
    };

    pods = {
      minecraft121 = {};
    };
  };
}
