{
  config,
  deployment,
  ...
}: {
  containers.vaultwarden = deployment.mkContainer "vaultwarden" {
    bindMounts = {
      "/mount/Deneb/Vaultwarden".isReadOnly = false;
    };

    config = {
      networking = {
        firewall.enable = false;
        defaultGateway.address = deployment.containerHostIp "gateway";
      };

      services.vaultwarden = {
        enable = true;
        config = {
          DOMAIN = "https://thevault.drinkmymilk.org/";
          SIGNUPS_ALLOWED = false;
          ROCKET_ADDRESS = "0.0.0.0";
          ROCKET_PORT = 8080;

          ROCKET_LOG = "critical";

          ADMIN_TOKEN = "$argon2id$v=19$m=524288,t=12,p=4$ZVZZa2gyVVEzR3NZOTNOSlJaN0xKN0V6Q0taZDNYbWVPZWd2QXRadW53WT0$EZaul6/qXBik3/AMVYSaNy6vH1KU4yVGfpjcCVGtXTU";
        };
      };

      system.stateVersion = "23.11";
    };
  };
}
