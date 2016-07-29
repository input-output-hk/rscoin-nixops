{ config, pkgs, lib, ... } :

with lib;

let

  cfg = config.services.rscoin-explorer;
  name = "rscoin-explorer";

  stateDir = "/var/lib/rscoin-explorer/";
  configFile = pkgs.writeText "rscoin-explorer.conf" 
  ''
  ''; #TODO Fill me with Love ♥♥♥
  rscoin = pkgs.callPackage ./default.nix { };
in
{
  options = {
    services.rscoin-explorer = {
      enable = mkEnableOption name;
      port-rpc = mkOption {
        type = types.int;
        default = 5432;
        description = ''a port where it listens for bank updates'';
      };
      port-web = mkOption {
        type = types.int;
        default = 8000;
        description = ''a port where frontend `websockets` will connect to'';
      };
      sk-path = mkOption {
        type = types.path;
        default = "/rscoin/default.sec";
        description = ''a secret key of this binary'';
      };
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.rscoin-explorer = {
        #note this is a hack since this is not commited to the nixpkgs
        uid             = 2147483645;
        description     = "rscoin-explorer server user";
        group           = "rscoin";
        home            = stateDir;
        createHome      = true;
      };

      groups.rscoin = {
        #note this is a hack since this is not commited to the nixpkgs
        gid = 2147483646;
      };
    };

    systemd.services.rscoin-explorer = {
      description   = "rscoin explorer service";
      wantedBy      = [ "multi-user.target" ];
      after         = [ "network.target" ];

      preStart = ''
      ''; #TODO probably nothing to do

      serviceConfig = {
        User = "rscoin-explorer";
        Group = "rscoin";
        Restart = "always";
        KillSignal = "SIGINT";
        WorkingDirectory = stateDir;
        PrivateTmp = true;
        ExecStart = toString [
          "${rscoin}/bin/rscoin-explorer"
#          "--config=${cfg.configFile}"
        ];
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port-rpc cfg.port-web ];
  };
}
