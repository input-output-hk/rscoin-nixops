let
  region = "eu-central-1";
  accessKeyId = "rscoin-guest-user";

  bankIp = "52.59.5.254";
  notaryIp = "52.59.70.19";
  bankPort = 8123;
  notaryPort = 3123;
  mintettePort = 3100;
  explorerRpcPort = 5432;
  explorerWebPort = 8000;

  pubKey = "k2oIF6OH7uXCM4HZj06SV0eV3EJQ6nNBeyXYEdSBY1g=";
 
  volhovmKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRMQ16PB/UvIEF+UIHfy66FNaBUWgviE2xuD5qoq/nXURBsHogGzv1ssdj1uaLdh7pZxmo/cRC+Y5f6dallIHHwdiKKOdRq1R/IWToMxnL/TTre+px6rxq21al9r4lvibelIU9vDn0R6OFZo+pRWyXUm33bQ4DVhwWiSls3Hw+9xRq4Pf2aWy//ey5CUTW+QkVdDIOFQG97kHDO3OdoNuaOMdeS+HBgH25bzSlcMw044T/NV9Cyi3y1eEBCoyqA9ba28GIl3vNADBdoQb5YYhBViFLaFsadzgWv5XWTpXV4Kwnq8ekmTcBkDzoTng/QOrDLsFMLo1nEMvhbFZopAfZ volhovm.cs@gmail.com";
  shershKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOgln1GGTaghj8cAyRd9wPJWfwsFBgGY0axzVno7hlwEySDWQCcMtUysQ5N16k3R/Wc234ELPG03yJks1wmV8lncyuGSm3iEPf1zDPE5wvZIGHOZmC6r5iLezYEFqK6itz2I7TbNrNaoabTbIaJD5KZzuclnnM07ZbGTT8a+udidoav0lsJOnfprSG07g7WAjrbNs0Kokt1WIl7Rr0KBYr79Ys8WZlbKKJthsl8nAiE6Gj+6VZjHYf28QkaiNB+9MJHaYYfE3muCw0TXaWbKSHW8Mfmyiz8FiKH4/cYVvhNSd3rTygz3JQoVlRcEQcSuAxIhLeYemOGQO0cUYfTlLF fenx@smachine";
  akegaljKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCn11qMrU3M+k/S5ScA8C37pPB7XNxzOmBnF89NkjJ16JhZxlX5tqEfq2Arja+nEG6UB8Js/5MsWTRkVYK6pB+ju0RAb5qyYomU/zZBhf9yOLlWuXTCV1ptdwRxLptjRdJ9a9YC0q715ZnNoIhfbVoR8o/CYLBFKFdFcV8O87R6mWPJ1I2CgTtfW3zjlFD8xRXtirio5EzNaq/Tq4ClQdpAOlfwHErxfk/TQMFY7vLiBdd26YEn+zD95xF4EX9cT7A2BHFD3U7OioTOTiyRwhaP3dFPcy+51fKGvxhBXtdb0fu+OanjQjsezmnBXwzSprKJUj6VjFoB4yt5qHqj0ntx akegalj@gmail.com"; 
  devKeys = [volhovmKey shershKey akegaljKey];

  defaultPackages = { pkgs }:
    let rscoin = import ./default.nix { inherit pkgs; };
    in with pkgs; [ git tmux vim nixops rscoin ];

# discription of the service types
# important note, enable firewalls again.
  bank = {resources, pkgs, ...}:{
    deployment.targetEnv = "ec2";
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.instanceType = "t2.medium";
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
    users.extraUsers.root.openssh.authorizedKeys.keys = devKeys;

    environment.systemPackages = defaultPackages { inherit pkgs; };

    services.rscoin-bank = {
      enable = true;

      host = bankIp;
      port = bankPort;
      publicKey = pubKey;
      skPath = "/secret/key.sec";
      periodDelta = 500;

      notary = {
        host = notaryIp;
        port = notaryPort;
      };
    };

    networking.firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 22 bankPort ];
    };

  };

  notary = {resources, pkgs, ...}:{
    deployment.targetEnv = "ec2";
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.keyPair = resources.ec2KeyPairs.my-key-pair;
    deployment.ec2.securityGroups = ["rscoin-deploy-sec-group"];

    imports = [ ./rscoin-notary.nix ];

    users.extraUsers.root.openssh.authorizedKeys.keys = devKeys;
    services.openssh.enable = true;

    environment.systemPackages = defaultPackages { inherit pkgs; };

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

    networking.firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 22 notaryPort ];
    };
  };

  mintette = {resources, pkgs, ...}:{
    deployment.targetEnv = "ec2";
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.keyPair = resources.ec2KeyPairs.my-key-pair;
    deployment.ec2.securityGroups = ["rscoin-deploy-sec-group"];

    imports = [ ./rscoin-mintette.nix ];

    users.extraUsers.root.openssh.authorizedKeys.keys = devKeys;
    services.openssh.enable = true;

    environment.systemPackages = defaultPackages { inherit pkgs; };

    services.rscoin-mintette = {
      enable = true;
   
      port = mintettePort;

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

    networking.firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 22 mintettePort ];
    };
  };


  block-explorer = {resources, pkgs, ...}:{
    deployment.targetEnv = "ec2";
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.keyPair = resources.ec2KeyPairs.my-key-pair;
    deployment.ec2.securityGroups = ["rscoin-deploy-sec-group"];

    imports = [ ./rscoin-block-explorer.nix ];

    services.openssh.enable = true;
    users.extraUsers.root.openssh.authorizedKeys.keys = devKeys;

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

    environment.systemPackages = defaultPackages { inherit pkgs; };

    networking.firewall = {
      enable = true; 
      allowPing = true;
      allowedTCPPorts = [
        22
        explorerRpcPort explorerWebPort
        80 443                          # http/https
      ];
      allowedUDPPorts = [
#         655              # tinc
#         50428 35948 53913 51413 5350 5351 # transmission
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
  rs-mintette1 = mintette;
  rs-mintette2 = mintette;
  rs-mintette3 = mintette;
  block-explorer = block-explorer;

  resources.ec2KeyPairs.my-key-pair =
    { inherit region accessKeyId; };
}
