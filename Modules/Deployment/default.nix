# Alot of the inspiration and part of the implementation is largely due in part to outfoxxed
# great dev and was gracious enough to let me him copy him here.
{
  lib,
  config,
  deployment,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.modules) mkIf;

  containerNames = lib.attrNames config.containers;
  cfg = config.deployment;
in {
  options.deployment = {
    mainInterface = mkOption {
      type = lib.types.str;
      default = "eth0";
      description = "Main external networking interface";
    };
  };

  config = {
    _module.args.deployment = let
      indexOf = list: elem: let
        f = f: i:
          if i == (builtins.length list)
          then null
          else if (builtins.elemAt list i) == elem
          then i
          else f f (i + 1);
      in
        f f 0;
    in {
      # This is IP of the containers bridge.
      nameservers = ["1.1.1.1" "1.0.0.1"];

      # Using containers list, we give our containers ips based off their index in the list
      # First container in list will be 192.168.100.11, then auto incrementing from there, this
      # meaning that IP's for containers will probably change fairly rapidly, so they SHOULD not
      # called via a regular string. ie doing ip = "192.168.100.11"; BAD!
      containerHostIp = container: let
        index = indexOf containerNames container;
      in
        assert index != null; "192.168.100.${builtins.toString (index + 11)}";

      # Helper function for making containers a little more convenient, call with:
      # containers.<name> = mkContainer <name> { //... };
      # mkContainer = name: conf: let
      # in
      #   {
      #     autoStart = true;
      #     privateNetwork = true;
      #     hostBridge = "ncon0";
      #     hostAddress = "192.168.100.10";
      #     localAddress = "${deployment.containerHostIp name}/24";
      #
      #     config = {
      #       networking.nameservers = ["1.1.1.1" "8.8.8.8"];
      #     };
      #   }
      #   // conf;

      mkContainer = name: conf: let
      in
        lib.recursiveUpdate {
          autoStart = true;
          privateNetwork = true;
          hostBridge = "ncon0";
          hostAddress = "192.168.100.10";
          localAddress = "${deployment.containerHostIp name}/24";

          config = {
            services.resolved.enable = true;
            networking = {
              useHostResolvConf = false;
              nameservers = ["1.1.1.1" "1.0.0.1"];
            };
          };
        }
        conf;
    };

    networking = mkIf (config.containers != {}) {
      bridges = {
        ncon0.interfaces = [];
      };

      interfaces = {
        ncon0.ipv4.addresses = [
          {
            address = "192.168.100.10";
            prefixLength = 24;
          }
        ];
      };

      nat = {
        enable = true;
        externalInterface = cfg.mainInterface;
        internalInterfaces = ["ncon0"];
      };
    };
  };
}
