{ config, pkgs, lib, ... } :

with lib;

let

  cfg = config.services.rscoin-block-explorer;
  name = "rscoin-block-explorer";

  stateDir = "/var/lib/rscoin-block-explorer/";
  configFile = pkgs.writeText "rscoin-block-explorer.conf" ''
    bank {
      host       = "cfg.bankIP"
      port       = cfg.bankPort
      publicKey  = "cfg.bankPubKey"
    }

    notary {
      host = "cfg.notaryIP"
      port = cfg.notaryPort
    }
  '';

  rscoin = pkgs.callPackage ./default.nix { };
  block-explorer-static-files = pkgs.callPackage ./block-explorer/default.nix { };
in
{
  options = {
    services.rscoin-block-explorer = {
      enable = mkEnableOption name;
      port = mkOption {
        type = types.int;
        default = 80;
        description = ''The TCP port where rscoin-block-explorer (nginx) server will listen on.'';
      };
      bankIP = mkOption {
        default = "0.0.0.0";
        description = ''The IPv4 address where rscoin-explorer will expect a `bank` instance.'';
      };
      bankPort = mkOption {
        type = types.int;
        default = 1234;
        description = ''The TCP port where rscoin-explorer will expect a `bank` instance.'';
      };
      notaryIP = mkOption {
        default = "0.0.0.0";
        description = ''The IPv4 address where rscoin-explorer will expect a `notary` instance.'';
      };      notaryPort = mkOption {
        type = types.int;
        default = 1234;
        description = ''The TCP port where rscoin-explorer will expect a `notary` instance.'';
      };
      configFile = mkOption {
        default = "";
        description = "Verbatim contents of the config file.";
      };
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.rscoin-block-explorer = {
        #note this is a hack since this is not commited to the nixpkgs
        uid             = 2147483644;
        description     = "rscoin-block-explorer server user";
        group           = "rscoin";
        home            = stateDir;
        createHome      = true;
      };
    };

#     groups.rscoin = {
#       gid = 2147483646;
#     };

    systemd.services.rscoin-explorer = {
      description   = "rscoin block explorer service";
      wantedBy      = [ "multi-user.target" ];
      after         = [ "network.target" ];

#       preStart = ''
#       '';

      serviceConfig = {
        User = "rscoin-block-explorer";
        Group = "rscoin";
        Restart = "always";
        KillSignal = "SIGINT";
        WorkingDirectory = stateDir;
        PrivateTmp = true;
        ExecStart = toString [
          "${rscoin}/bin/rscoin-explorer"
          "--config=${cfg.configFile}"
        ];
      };
    };

    # serves static files and redirects websocket
    services.nginx = {
      enable = true;
      config = ''
        error_log  ${stateDir}/error.log;
        
        events {}
        
        http {
          server {
            access_log ${stateDir}/access.log;
            listen ${toString cfg.port};
            root ${block-explorer-static-files}/share/;

#             location / {
#               proxy_pass http://localhost:2000/;
#             }

            location /websocket {
              proxy_pass http://localhost:3001/websocket;
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
            }
          }
        }
      '';
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
