{ config, pkgs, lib, ... } :

with lib;

let

  cfg = config.services.rscoin-bank;
  name = "rscoin-bank";

  stateDir = "/var/lib/rscoin-bank/";
  configFile = pkgs.writeText "rscoin-bank.conf" 
  ''
  ''; #TODO Fill me with Love ♥♥♥
  rscoin = pkgs.callPackage ./default.nix { };
in
{
  options = {
    services.rscoin-bank = {
      enable = mkEnableOption name;
      
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
#          "${rscoin}/bin/rscoin-bank"
          "${rscoin}/bin/rscoin-bank"
#          "--config=${cfg.configFile}"
        ];
      };
    };

    networking.firewall.allowedUDPPorts = [ cfg.port ];
  };
}
