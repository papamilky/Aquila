{deployment, ...}: let
  domainName = "git.drinkmymilk.org";
in {
  containers.forgejo = deployment.mkContainer "forgejo" {
    config = {config, ...}: {
      environment.systemPackages = [config.services.forgejo.package];

      networking = {
        firewall.enable = false;
        defaultGateway.address = deployment.containerHostIp "gateway";
      };

      services = {
        forgejo = {
          enable = true;
          settings = {
            DEFAULT.APP_NAME = "Forgejo";
            repository.DEFAULT_BRANCH = "master";
            ui.DEFAULT_THEME = "forgejo-dark";
            service.DISABLE_REGISTRATION = true;
            database.SQLITE_JOURNAL_MODE = "WAL";
            metrics.ENABLED = true;
            security.REVERSE_PROXY_TRUSTED_PROXIES = "10.0.0.1";

            server = {
              HTTP_ADDR = deployment.containerHostIp "forgejo";
              HTTP_PORT = 4000;
              DOMAIN = "${domainName}";
              ROOT_URL = "https://${domainName}/";

              START_SSH_SERVER = true;
              BUILTIN_SSH_SERVER_USER = "git";
              SSH_LISTEN_HOST = deployment.containerHostIp "forgejo";
              SSH_LISTEN_PORT = 2000;
            };

            cache = {
              ADAPTER = "twoqueue";
              HOST = ''{"size":100, "recent_ratio":0.25, "ghost_ratio":0.5}'';
            };

            "ui.meta" = {
              AUTHOR = "Forgejo";
              DESCRIPTION = "kossLAN's self-hosted git instance";
            };
          };
        };
      };

      system.stateVersion = "23.11";
    };
  };
}
