#!/bin/sh

function deploy { 
  nixops deploy -d rscoin -I nixpkgs=../nixpkgs/
}

echo "Creating a deployment..."
nixops create nixops.nix -d rscoin
echo "Initial deployment and keys generation will start in seconds..."
sleep 1
deploy
echo "Querying bank key"
bankKey=$(nixops ssh rs-bank -- cat /var/lib/rscoin-bank/.rscoin/bankKey.pub)
echo "Bank's public key is $bankKey"
sed -i -e "s/\s*pubKey\s*=\s*.*/  pubKey = \"$bankKey\";/" nixops.nix 
echo "Redeploying with new generated key"
deploy
