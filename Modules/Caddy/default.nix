{
  lib,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;

  cfg = config.services.caddy;
in {
  options.services.caddy = {
    domains = mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          reverseProxyList = mkOption {
            type = lib.types.listOf (lib.types.submodule {
              options = {
                subdomain = mkOption {
                  type = lib.types.str;
                  default = "";
                };

                address = mkOption {
                  type = lib.types.str;
                  default = "";
                };

                port = mkOption {
                  type = lib.types.int;
                  default = 80;
                };

                extraConfig = mkOption {
                  type = lib.types.str;
                  default = "";
                };
              };
            });
          };

          fileServer = mkOption {
            type = lib.types.nullOr (lib.types.submodule {
              options = {
                subdomain = mkOption {
                  type = lib.types.str;
                  default = "";
                  description = "Optional subdomain to serve the file server from.";
                };

                root = mkOption {
                  type = lib.types.str;
                  description = "Path to serve files from.";
                };

                browse = mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Enable directory browsing.";
                };

                extraConfig = mkOption {
                  type = lib.types.str;
                  default = "";
                };
              };
            });
            default = null;
          };
        };
      });

      default = {};

      description = ''
        List of reverse proxies for various services, mapped to caddy.
        -- Example:
        domains = {
          "kosslan.me" = {
            reverseProxyList = [
              {
                subdomain = "sync";
                address = "localhost";
                port = 8384;
              }
            ];
          };
        };
      '';
    };

    cfKeyFile = mkOption {
      type = lib.types.path;
      default = config.sops.secrets."cloudflare/apiToken".path;
      description = ''
        Path to the cloudflare key file.
      '';
    };

    readOnlyPaths = mkOption {
      type = lib.types.listOf lib.types.path;
      default = [];
      description = "Paths to expose as read-only to the Caddy systemd service.";
    };

    allowedPaths = mkOption {
      type = lib.types.listOf lib.types.path;
      default = [];
      description = "Paths to expose as read-write to the Caddy systemd service.";
    };
  };

  config = mkIf (cfg.domains != []) {
    sops.secrets = {
      "cloudflare/apiToken" = {};
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "acme@drinkmymilk.org";
      certs =
        lib.mapAttrs (name: _: {
          group = "caddy";
          reloadServices = ["caddy.service"];
          dnsProvider = "cloudflare";
          dnsResolver = "ns.cloudflare.com:53";
          extraDomainNames = ["*.${name}"];
          environmentFile = cfg.cfKeyFile;
        })
        cfg.domains;
    };

    services.caddy = {
      email = "acme@drinkmymilk.org";
      virtualHosts = lib.foldl' (
        acc: domain: let
          domainCfg = cfg.domains.${domain};
          # Build fileServer block if defined
          fileHost =
            if domainCfg.fileServer != null
            then {
              "${domainCfg.fileServer.subdomain}.${domain}" = {
                extraConfig = ''
                  root * ${domainCfg.fileServer.root}
                  file_server ${lib.optionalString domainCfg.fileServer.browse "browse"}

                  ${domainCfg.fileServer.extraConfig}
                  tls /var/lib/acme/${domain}/cert.pem /var/lib/acme/${domain}/key.pem
                '';
              };
            }
            else {};
          # Build reverseProxy entries
          proxyHosts =
            lib.foldl' (
              innerAcc: proxy:
                innerAcc
                // {
                  "${
                    if proxy.subdomain == ""
                    then domain
                    else "${proxy.subdomain}.${domain}"
                  }" = {
                    extraConfig = ''
                      ${
                        if proxy.address != ""
                        then "reverse_proxy http://${proxy.address}:${toString proxy.port}"
                        else ""
                      }

                      ${proxy.extraConfig}
                      tls /var/lib/acme/${domain}/cert.pem /var/lib/acme/${domain}/key.pem
                    '';
                  };
                }
            ) {}
            domainCfg.reverseProxyList;
        in
          acc // proxyHosts // fileHost
      ) {} (lib.attrNames cfg.domains);
    };
  };
}
