let
  region = "eu-west-1";
  accessKeyId = "dev";

  bankIp = "52.59.74.68";
  notaryIp = "52.59.70.19";
  bankPort = 8123;
  notaryPort = 3123;

  pubKey = "k2oIF6OH7uXCM4HZj06SV0eV3EJQ6nNBeyXYEdSBY1g=";

# discription of the service types
# important note, enable firewalls again.
  bank = {resources, pkgs, ...}:{
    deployment.targetEnv = "ec2";
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.keyPair = resources.ec2KeyPairs.my-key-pair;
    deployment.ec2.securityGroups = ["rscoin-deploy-sec-group"];

    imports = [ ./rscoin-bank.nix ];

    services.openssh.enable = true;
    users.extraUsers.guest = {
	name = "rscoin";
	group = "user";
	uid = 1000;
	createHome = true;
	home = "/home/rscoin";
	shell = "/run/current-system/sw/bin/bash";
    };

    environment.systemPackages = with pkgs; [
      git
      tmux
      vim
      nixops
    ];

    services.rscoin-bank = {
      enable = true;

      host = bankIp;
      port = bankPort;
      publicKey = pubKey;
      skPath = "/secret/key.sec";

      notary = {
        host = notaryIp;
        port = notaryPort;
      };
    };
    networking.firewall.enable = false;
  };

  notary = {resources, pkgs, ...}:{
    deployment.targetEnv = "ec2";
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.keyPair = resources.ec2KeyPairs.my-key-pair;
    deployment.ec2.securityGroups = ["rscoin-deploy-sec-group"];

    imports = [ ./rscoin-notary.nix ];

    environment.systemPackages = with pkgs; [
      git
      tmux
      vim
      nixops
    ];

    services.rscoin-notary = {
      enable = true;
      host = notaryIp;
      port = notaryPort;
      debug = true;

      bank = {
        host = bankIp;
        port = bankPort;
        publicKey = pubKey;
      };
    };
    networking.firewall.enable = false;
  };

  mintette = {resources, pkgs, ...}:{
    deployment.targetEnv = "ec2";
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.keyPair = resources.ec2KeyPairs.my-key-pair;
    deployment.ec2.securityGroups = ["rscoin-deploy-sec-group"];

    imports = [ ./rscoin-mintette.nix ];

    users.extraUsers.root.openssh.authorizedKeys.keys = 
      [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRMQ16PB/UvIEF+UIHfy66FNaBUWgviE2xuD5qoq/nXURBsHogGzv1ssdj1uaLdh7pZxmo/cRC+Y5f6dallIHHwdiKKOdRq1R/IWToMxnL/TTre+px6rxq21al9r4lvibelIU9vDn0R6OFZo+pRWyXUm33bQ4DVhwWiSls3Hw+9xRq4Pf2aWy//ey5CUTW+QkVdDIOFQG97kHDO3OdoNuaOMdeS+HBgH25bzSlcMw044T/NV9Cyi3y1eEBCoyqA9ba28GIl3vNADBdoQb5YYhBViFLaFsadzgWv5XWTpXV4Kwnq8ekmTcBkDzoTng/QOrDLsFMLo1nEMvhbFZopAfZ volhovm.cs@gmail.com" ];
    services.openssh.enable = true;

    environment.systemPackages = with pkgs; [
      git
      tmux
      vim
      nixops
    ];

    services.rscoin-mintette = {
      enable = true;
      port = 3001;

      notary = {
        host = notaryIp;
        port = notaryPort;
      };

      bank = {
        host = bankIp;
        port = bankPort;
        publicKey = pubKey;
      };
    };

    networking.firewall.enable = false;
  };


  block-explorer = {resources, pkgs, ...}:{
    deployment.targetEnv = "ec2";
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.keyPair = resources.ec2KeyPairs.my-key-pair;
    deployment.ec2.securityGroups = ["rscoin-deploy-sec-group"];

    imports = [ ./rscoin-block-explorer.nix ];

    services.rscoin-block-explorer = {
      enable = true;
      port = 80;
      bankIP = bankIp;
      bankPort = bankPort;
      notaryIP = notaryIp;
      notaryPort = notaryPort;
      bankPubKey = pubKey;
    };

# Want to have an extra user for external ssh access, use this:
#     users.extraUsers.guest = {
#       name = "rscoin";
#       group = "users";
#       uid = 1000;
#       createHome = true;
#       home = "/home/rscoin";
#       shell = "/run/current-system/sw/bin/bash";
#       openssh.authorizedKeys.keys = [ "ssh-rsa AA....." ];
#     };
#    services.openssh.enable = true;
    
    environment.systemPackages = with pkgs; [
      git
      tmux
      vim
      nixops
    ];

    networking.firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [
        22
        80 443           # http/https
      ];
      allowedUDPPorts = [
#         655              # tinc
        #50428 35948 53913 51413 5350 5351 # transmission
#         64738            # murmurd (mumble)
      ];
    };
  };


in
{
  #actual deployment of machines.
  # want to add more machines of any type add them here.
  # for example 
  # rs-custom-mintette = mintette;
  # would add another mintette server with the name rs-custom-mintette

  rs-bank = bank;
  rs-notary = notary;
  rs-mintette = mintette;
  rs-mintette2 = mintette;
  rs-mintette3 = mintette;
  block-explorer = block-explorer;

  resources.ec2KeyPairs.my-key-pair =
    { inherit region accessKeyId; };
}
