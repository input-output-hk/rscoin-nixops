{ config, pkgs, lib, ... } :

with lib;

let

  cfg = config.services.rscoin-block-explorer;
  name = "rscoin-block-explorer";

  stateDir = "/var/lib/rscoin-block-explorer/";
  configFile = pkgs.writeText "rscoin-block-explorer.conf" 
  ''
  ''; #TODO Fill me with Love ♥♥♥
  #rscoin = pkgs.callPackage ./default.nix { }; # not needed
  block-explorer = pkgs.callPackage ./block-explorer/default.nix { };
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

    services.nginx = {
      enable = true;
      config = ''
        error_log  ${stateDir}/error.log;
        
        events {}
        
        http {
          server {
            access_log ${stateDir}/access.log;
            listen ${toString cfg.port};
            root ${block-explorer}/share/;
          }
        }
      '';
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
