{ config, pkgs, lib, ... } :

with lib;

let

  cfg = config.services.rscoin-bank;
  name = "rscoin-bank";

  stateDir = "/var/lib/rscoin-bank/";
  rscoin = pkgs.callPackage ./default.nix { };
  
  rscoinConfig = pkgs.writeText "rscoin-bank.conf" 
    ''
      bank {
        host        = "${cfg.host}"
        port        = ${toString cfg.port}
        publicKey   = "${cfg.publicKey}"
      }

      notary {
        host        = "${cfg.notary.host}"
        port        = ${toString cfg.notary.port}
      }
    '';
in
{
  options = {
    services.rscoin-bank = {
      enable = mkEnableOption name;

      host = mkOption {
        type = types.string;
        default = "127.0.0.1";
      };

      publicKey = mkOption {
        type = types.string;
#        default = "YblQ7+YCmxU/4InsOwSGH4Mm37zGjgy7CLrlWlnHdnM=";
      };
      
      port = mkOption {
        type = types.int;
        default = 3123;
      };

      skPath = mkOption {
        type = types.path;
        default = builtins.toPath "${stateDir}/.rscoin/bankKey";
        description = "the path to the secret bank key";
      };

      notary = mkOption{
        default = {
          host = "127.0.0.1";
          port = 8123;
        };
      };

      debug = mkOption {
        type = types.bool;
        default = true;
      };

      configFile = mkOption {
        default = "";
        description = "Verbatim contents of the config file.";
      };

      periodDelta = mkOption {
        type = types.int;
        default = 100;
        description = "Period delta in seconds.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.rscoin-bank.configFile = rscoinConfig;
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

    environment.variables = { RSCOIN_CONFIG = "${rscoinConfig}"; };

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
          "${rscoin}/bin/rscoin-bank serve"
          "--config-path ${cfg.configFile}"
          "-k ${cfg.skPath}"
          "--period-delta ${toString cfg.periodDelta}"
          "--auto-create-sk"
          (if cfg.debug then " --log-severity Debug" else "")
        ];
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
