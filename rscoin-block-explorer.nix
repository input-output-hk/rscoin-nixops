{ config, pkgs, lib, ... } :

with lib;

let

  cfg = config.services.rscoin-block-explorer;
  name = "rscoin-block-explorer";

  stateDir = "/var/lib/rscoin-block-explorer/";

  rscoin = pkgs.callPackage ./default.nix { };
  block-explorer-static-files = pkgs.callPackage ./block-explorer/default.nix { };

  rscoinConfig = pkgs.writeText "rscoin-block-explorer.conf" ''
      bank {
        host       = "${cfg.bankIP}"
        port       = ${toString cfg.bankPort}
        publicKey  = "${cfg.bankPubKey}"
      }

      notary {
        host = "${cfg.notaryIP}"
        port = ${toString cfg.notaryPort}
      }
    '';
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
      bankPubKey = mkOption {
        default = ">> you need to set the public key using nix configuration magic <<";
        description = ''The public key of the `bank` rscoin-explorer will use to contact the `bank`.'';
      };      
      notaryIP = mkOption {
        default = "0.0.0.0";
        description = ''The IPv4 address where rscoin-explorer will expect a `notary` instance.'';
      };      
      notaryPort = mkOption {
        type = types.int;
        default = 1234;
        description = ''The TCP port where rscoin-explorer will expect a `notary` instance.'';
      };
      wsPort = mkOption {
        type = types.int;
        default = 3001;
        description = ''The TCP port where rscoin-explorer will listen with a `websocket`.'';
      };
      rpcPort = mkOption {
        type = types.int;
        default = 3000;
        description = "The TCP port where rscoin-explorer will be pinged by `bank`.";
      };
      configFile = mkOption {
        default = "";
        description = "Verbatim contents of the config file.";
      };
      debug= mkOption { 
        type = types.bool;  
        default = true;
        description = "Debug output verbosity level.";
      }; 
      keyPath = mkOption {
        default = "/secret/key.sec";
        description = "Path to explorer's secret key.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.rscoin-block-explorer.configFile = rscoinConfig;
 
    users = {
      users.rscoin-block-explorer = {
        #note this is a hack since this is not commited to the nixpkgs
        uid             = 2147483644;
        description     = "rscoin-block-explorer server user";
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
          "--config-path=${cfg.configFile}"
          "--port-rpc ${toString cfg.rpcPort}"
          "--port-web ${toString cfg.wsPort}"
          "--sk ${cfg.keyPath}"
          (if cfg.debug then " --log-severity Debug" else "")
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
 
            location /index.html { 
#              rewrite ^/index\.html$ / break;
            }

            location / {
              rewrite ^/address/.*$ / break;
            } 
 
            location /websocket {
              proxy_pass http://localhost:${toString cfg.wsPort}/websocket;
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
