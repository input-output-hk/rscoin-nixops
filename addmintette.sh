#!/bin/sh
source ./parseNix.sh
echo "Getting host..."
mintetteHost=$(nixops info -d rscoin | grep $1 | sed -e "s/.*|\s\([0-9\.]\+\)\s*|\s*/\1/")
echo "Mintette $1 is on $mintetteHost, getting key"
mintetteKey=$(nixops ssh $1 -- cat /var/lib/rscoin-mintette/.rscoin/mintette${NIXOPS_MINTETTE_PORT}Key.pub)
echo "Has key $mintetteKey, now adding it to the bank"
nixops ssh rs-bank -- rscoin-bank --log-severity Debug --secret-key /var/lib/rscoin-bank/.rscoin/bankKey --config-path \$RSCOIN_CONFIG add-mintette --key $mintetteKey --host $mintetteHost --port $NIXOPS_MINTETTE_PORT
