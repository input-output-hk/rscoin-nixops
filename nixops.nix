let
  region = "eu-west-1";
  accessKeyId = "dev";

  bankIp = "52.209.108.123";
  notaryIp = "52.17.237.225";
  bankPort = 8123;
  notaryPort = 3123;

  pubKey = "YblQ7-YCmxU_4InsOwSGH4Mm37zGjgy7CLrlWlnHdnM=";


  bank = {resources, ...}:{
    deployment.targetEnv = "ec2";
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.keyPair = resources.ec2KeyPairs.my-key-pair;
    deployment.ec2.securityGroups = ["rscoin-deploy-sec-group"];

    imports = [ ./rscoin-bank.nix ];
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
  };

  notary = {resources, ...}:{
    deployment.targetEnv = "ec2";
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.keyPair = resources.ec2KeyPairs.my-key-pair;
    deployment.ec2.securityGroups = ["rscoin-deploy-sec-group"];

    imports = [ ./rscoin-notary.nix ];

    services.rscoin-notary = {
      enable = true;
      host = notaryIp;
      port = notaryPort;

      bank = {
        host = bankIp;
        port = bankPort;
        publicKey = pubKey;
      };
    };
  };

  mintette = {resources, ...}:{
    deployment.targetEnv = "ec2";
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.keyPair = resources.ec2KeyPairs.my-key-pair;
    deployment.ec2.securityGroups = ["rscoin-deploy-sec-group"];

    imports = [ ./rscoin-mintette.nix ];

    services.rscoin-mintette = {
      enable = true;
      port = 3000;

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

#     users.extraUsers.guest = {
#       name = "rscoin";
#       group = "users";
#       uid = 1000;
#       createHome = true;
#       home = "/home/rscoin";
#       shell = "/run/current-system/sw/bin/bash";
#     };

    services.openssh.enable = true;
    
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
  rs-bank = bank;
  rs-notary = notary;
  rs-mintette = mintette;
  block-explorer = block-explorer;



  resources.ec2KeyPairs.my-key-pair =
    { inherit region accessKeyId; };
}
