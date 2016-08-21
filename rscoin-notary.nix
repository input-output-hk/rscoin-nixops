{ config, pkgs, lib, ... } :

with lib;

let

  cfg = config.services.rscoin-notary;
  name = "rscoin-notary";

  stateDir = "/var/lib/rscoin-notary/";
  rscoin = pkgs.callPackage ./default.nix { };
  
  rscoinConfig = pkgs.writeText "rscoin-notary.conf" 
    ''
      bank {
        host        = "${cfg.bank.host}"
        port        = ${toString cfg.bank.port}
        publicKey   = "${cfg.bank.publicKey}"
      }
      notary {
        host        = "${cfg.host}"
        port        = ${toString cfg.port}
      }
    ''; 
in
{
  options = {
    services.rscoin-notary = {
      enable = mkEnableOption name;

      debug = mkOption {
        type = types.bool;
        default = false;        
      };

      port = mkOption {
        type = types.int;
        default = 8000;
      };

      host = mkOption {
        type = types.string;
        default = "127.0.0.1";
      };

      bank = mkOption{
        default = {
          host = "127.0.0.1";
          port = 8123;
          publicKey = "YblQ7+YCmxU/4InsOwSGH4Mm37zGjgy7CLrlWlnHdnM=";
        };
      };

      configFile = mkOption {
        default = "";
        description = "Verbatim contents of the config file.";
      };

    };
  };

  config = mkIf cfg.enable {
    services.rscoin-notary.configFile = rscoinConfig;

    users = {
      users.rscoin-notary = {
        #note this is a hack since this is not commited to the nixpkgs
        uid             = 2147483643;
        description     = "rscoin-notary server user";
        group           = "rscoin";
        home            = stateDir;
        createHome      = true;
      };

      groups.rscoin = {
        #note this is a hack since this is not commited to the nixpkgs
        gid = 2147483646;
      };
    };

    environment.variables = { RSCOIN_CONFIG = "${rscoinConfig}"; };
 
    systemd.services.rscoin-notary = {
      description   = "rscoin notary service";
      wantedBy      = [ "multi-user.target" ];
      after         = [ "network.target" ];

      preStart = ''
      ''; #TODO probably nothing to do

      serviceConfig = {
        User = "rscoin-notary";
        Group = "rscoin";
        Restart = "always";
        KillSignal = "SIGINT";
        WorkingDirectory = stateDir;
        PrivateTmp = true;
        ExecStart = (toString [
          "${rscoin}/bin/rscoin-notary"
          "--config-path ${cfg.configFile}"
        ]) + (if cfg.debug then " --log-severity Debug" else "");
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
