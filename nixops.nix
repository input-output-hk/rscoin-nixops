let
  region = "eu-west-1";
  accessKeyId = "dev";

  bank = {resources, ...}:{
    deployment.targetEnv = "ec2";
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.keyPair = resources.ec2KeyPairs.my-key-pair;
    deployment.ec2.securityGroups = ["rscoin-deploy-sec-group"];

    imports = [ ./rscoin-bank.nix ];
    services.rscoin-bank.enable = true;
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
    };
  };

  block-explorer = {resources, pkgs, ...}:{
    deployment.targetEnv = "ec2";
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.keyPair = resources.ec2KeyPairs.my-key-pair;
    deployment.ec2.securityGroups = ["rscoin-deploy-sec-group"];

    imports = [ ./rscoin-bank.nix ./rscoin-block-explorer.nix ];

    services.rscoin-bank = {
      enable = true;
    };
    services.rscoin-block-explorer = {
      enable = true;
      port = 80;
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
  block-explorer = block-explorer;

  resources.ec2KeyPairs.my-key-pair =
    { inherit region accessKeyId; };
}
