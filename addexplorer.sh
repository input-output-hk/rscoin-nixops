#!/bin/sh
echo "Getting host..."
explorerHost=$(nixops info -d rscoin | grep block-explorer | sed -e "s/.*|\s\([0-9\.]\+\)\s*|\s*/\1/")
echo "Explorer is on $explorerHost, getting key"
explorerKey=$(nixops ssh block-explorer -- cat /var/lib/rscoin-block-explorer/.rscoin/explorerKey.pub)
echo "Has key $explorerKey, now adding it to the bank"
nixops ssh rs-bank -- rscoin-bank --log-severity Debug --secret-key /var/lib/rscoin-bank/.rscoin/bankKey --config-path \$RSCOIN_CONFIG add-explorer --key $explorerKey --host $explorerHost --port 5432
