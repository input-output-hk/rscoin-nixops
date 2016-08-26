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
if [ -z $bankKey ]; then echo "[Error]. Bank key wasn't retrieved. Exiting." && exit; fi
echo "Bank's public key is $bankKey"
sed -i -e "s/\s*pubKey\s*=\s*.*/  pubKey = \"$bankKey\";/" nixops.nix 
echo "Redeploying with new generated key"
deploy
echo "Adding explorer"
./addexplorer.sh
