{ config, pkgs, lib, ... } :

with lib;

let

  cfg = config.services.rscoin-mintette;
  name = "rscoin-mintette";

  stateDir = "/var/lib/rscoin-mintette/";
  rscoin = pkgs.callPackage ./default.nix { };
  
  rscoinConfig = pkgs.writeText "rscoin-mintette.conf" 
    ''
      bank {
        host        = "${cfg.bank.host}"
        port        = ${toString cfg.bank.port}
        publicKey   = "${cfg.bank.publicKey}"
      }
      notary {
        host        = "${cfg.notary.host}"
        port        = ${toString cfg.notary.port}
      }
    '';
in
{
  options = {
    services.rscoin-mintette = {
      enable = mkEnableOption name;

      bank = mkOption{
        default = {
          host = "127.0.0.1";
          port = 8123;
          publicKey = "YblQ7+YCmxU/4InsOwSGH4Mm37zGjgy7CLrlWlnHdnM=";
        };
      };

      skPath = mkOption {
        type = types.path;
        default = "/secret/key.sec" ;
        description = "the path to the secret bank key";
      };

      port = mkOption {
        type = types.int;
        default = 3000;
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
    };
  };

  config = mkIf cfg.enable {
    services.rscoin-mintette.configFile = rscoinConfig;

    users = {
      users.rscoin-mintette = {
        uid             = 2147483642;
        description     = "rscoin-mintette server user";
        group           = "rscoin";
        home            = stateDir;
        createHome      = true;
      };

      groups.rscoin = {
        gid = 2147483646;
      };
    };

    environment.variables = { RSCOIN_CONFIG = "${rscoinConfig}"; };
    
    systemd.services.rscoin-mintette = {
      description   = "rscoin mintette service";
      wantedBy      = [ "multi-user.target" ];
      after         = [ "network.target" ];

      preStart = ''
      ''; #TODO probably nothing to do

      serviceConfig = {
        User = "rscoin-mintette";
        Group = "rscoin";
        Restart = "always";
        KillSignal = "SIGINT";
        WorkingDirectory = stateDir;
        PrivateTmp = true;
        ExecStart = toString [
          "${rscoin}/bin/rscoin-mintette"
          "--config-path ${cfg.configFile}"
          "--port ${toString cfg.port}"
          "--sk ${cfg.skPath}"
          (if cfg.debug then " --log-severity Debug" else "")
        ];
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
