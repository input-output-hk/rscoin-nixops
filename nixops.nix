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

    services.rscoin-bank.enable = true;
#     services.rscoin-block-explorer.enable = true; #not tested yet

    # TODO security
    networking.firewall.enable = false;

    users.extraUsers.guest = {
      name = "rscoin";
      group = "users";
      uid = 1000;
      createHome = true;
      home = "/home/rscoin";
      shell = "/run/current-system/sw/bin/bash";
    };

    services.openssh.enable = true;
    
    environment.systemPackages = with pkgs; [
      git
      tmux
      vim
      nixops
    ];

  };
in
{
  rscoin = ec2;
  resources.ec2KeyPairs.my-key-pair =
    { inherit region accessKeyId; };
}
