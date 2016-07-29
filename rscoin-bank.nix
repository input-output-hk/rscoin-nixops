{ config, pkgs, lib, ... } :

with lib;

let

  cfg = config.services.rscoin-bank;
  name = "rscoin-bank";

  stateDir = "/var/lib/rscoin-bank/";
  configFile = pkgs.writeText "rscoin-bank.conf" 
  ''
    bank {
        host        = ${host}
        port        = ${port}
        publicKey   = ${publicKey}
    }

    notary {
        host        = ${notary.host}
        port        = ${notary.port}
    }
  '';
  rscoin = pkgs.callPackage ./default.nix { };
in
{
  options = {
    services.rscoin-bank = {
      enable = mkEnableOption name;

      host = mkOption {
        type = types.string;
        default = "127.0.0.1";
      };

      publickKey = mkOption {
        type = types.string;
        default = "YblQ7+YCmxU/4InsOwSGH4Mm37zGjgy7CLrlWlnHdnM=";
      };
      
      port = mkOption {
        type = types.int;
        default = 3123;
      };

      skPath = mkOption {
        type = types.path;
        default = "/secret/bank.key" ;
      };

      notary = mkOption{
        default = {
          host = "127.0.0.1";
          port = 8123;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.rscoin-bank = {
        uid             = 2147483646;
        description     = "rscoin-bank server user";
        group           = "rscoin";
        home            = stateDir;
        createHome      = true;
      };

      groups.rscoin = {
        gid = 2147483646;
      };
    };

    systemd.services.rscoin-bank = {
      description   = "rscoin bank service";
      wantedBy      = [ "multi-user.target" ];
      after         = [ "network.target" ];

      preStart = ''
      ''; #TODO probably nothing to do

      serviceConfig = {
        User = "rscoin-bank";
        Group = "rscoin";
        Restart = "always";
        KillSignal = "SIGINT";
        WorkingDirectory = stateDir;
        PrivateTmp = true;
        ExecStart = toString [
          "${rscoin}/bin/rscoin-bank"
          "--config-path ${cfg.configFile}"
          "-k ${skPath}"
        ];
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
