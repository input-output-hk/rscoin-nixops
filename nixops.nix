let
  region = "eu-west-1";
  accessKeyId = "dev";

  bank = {resources, ...}:{
    deployment.targetEnv = "ec2";
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.keyPair = resources.ec2KeyPairs.my-key-pair;

    imports = [ ./rscoin-bank.nix ];
    services.rscoin-bank.enable = true;
  };

  notary = {resources, ...}:{
    deployment.targetEnv = "ec2";
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.keyPair = resources.ec2KeyPairs.my-key-pair;

    imports = [ ./rscoin-notary.nix ];
    services.rscoin-notary = {
      enable = true;
    }
  };


in
{
  rs-bank = bank;
  rs-notary = notary;


  resources.ec2KeyPairs.my-key-pair =
    { inherit region accessKeyId; };

}
