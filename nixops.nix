let
  region = "eu-west-1";
  accessKeyId = "dev";


  ec2 = { resources, config, pkgs, ... }:{
    deployment.targetEnv = "ec2";
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.keyPair = resources.ec2KeyPairs.my-key-pair;

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
  rscoin = ec2;
  resources.ec2KeyPairs.my-key-pair =
    { inherit region accessKeyId; };
}
