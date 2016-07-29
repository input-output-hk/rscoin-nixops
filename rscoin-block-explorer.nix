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
      
    };
  };

  config = mkIf cfg.enable {

    services.nginx = {
      enable = true;
      config = ''
        error_log  ${stateDir}/error.log;
        
        events {}
        
        http {
          server {
            access_log ${stateDir}/access.log;
            listen 80;
            root ${block-explorer}/share/;
          }
        }
      '';
    };

    networking.firewall.allowedUDPPorts = [ cfg.port ];
  };
}
