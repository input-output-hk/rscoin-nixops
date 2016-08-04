#!/bin/sh
nixops ssh rs-bank -- rscoin-bank --log-severity Debug --secret-key /secret/key.sec --config-path \$RSCOIN_CONFIG add-explorer --key $1 --host $2 --port $3
