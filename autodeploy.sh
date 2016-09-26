#!/bin/sh

function deploy { 
  nixops deploy -d rscoin -I nixpkgs=../nixpkgs/
}

echo "Cleaning up previous deployments"
./destroy.sh

echo "Creating a deployment..."
nixops create nixops.nix -d rscoin
echo "Initial deployment and keys generation will start in seconds..."
sleep 1

deploy
#if [ ! $? -eq 0 ]; then 
#  nixops destroy
#  nixops delete 
#  echo "Couldn't deploy, exiting" 
#  exit
#fi

echo "Querying bank key"
bankKey=$(nixops ssh rs-bank -- cat /var/lib/rscoin-bank/.rscoin/bankKey.pub)
if [ -z $bankKey ]; then echo "[Error]. Bank key wasn't retrieved. Exiting." && exit; fi
echo "Bank's public key is $bankKey"
sed -i -e "s/\s*bankPubKey\s*=\s*.*/  bankPubKey = \"$bankKey\";/" nixops.nix 

echo "Querying notary key"
notaryKey=$(nixops ssh rs-notary -- cat /var/lib/rscoin-notary/.rscoin/notaryKey.pub)
if [ -z $notaryKey ]; then echo "[Error]. Notary's key wasn't retrieved. Exiting." && exit; fi
echo "Notary's public key is $notaryKey"
sed -i -e "s/\s*notaryPubKey\s*=\s*.*/  notaryPubKey = \"$notaryKey\";/" nixops.nix 

echo "Redeploying with new generated keys"
deploy
echo "Adding explorer"
./addexplorer.sh
