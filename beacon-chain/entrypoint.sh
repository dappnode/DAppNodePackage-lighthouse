#!/bin/bash

# Concatenate EXTRA_OPTS string
[[ -n "$CHECKPOINT_SYNC_URL" ]] && EXTRA_OPTS="${EXTRA_OPTS} --checkpoint-sync-url=${CHECKPOINT_SYNC_URL}"

case $_DAPPNODE_GLOBAL_EXECUTION_CLIENT_MAINNET in
"geth.dnp.dappnode.eth")
    HTTP_ENGINE="http://geth.dappnode:8551"
    ;;
"nethermind.public.dappnode.eth")
    HTTP_ENGINE="http://nethermind.dappnode:8551"
    ;;
"erigon.dnp.dappnode.eth")
    HTTP_ENGINE="http://erigon.dappnode:8551"
    ;;
"besu.dnp.dappnode.eth")
    HTTP_ENGINE="http://besu.dappnode:8551"
    ;;
*)
    echo "Unknown value for _DAPPNODE_GLOBAL_EXECUTION_CLIENT_MAINNET: $_DAPPNODE_GLOBAL_EXECUTION_CLIENT_MAINNET"
    HTTP_ENGINE=$_DAPPNODE_GLOBAL_EXECUTION_CLIENT_MAINNET
    ;;
esac

# MEVBOOST: https://lighthouse-book.sigmaprime.io/builders.html
if [ -n "$_DAPPNODE_GLOBAL_MEVBOOST_MAINNET" ] && [ "$_DAPPNODE_GLOBAL_MEVBOOST_MAINNET" == "true" ]; then
    echo "MEVBOOST is enabled"
    MEVBOOST_URL="http://mev-boost.mev-boost.dappnode:18550"
    if curl --retry 5 --retry-delay 5 --retry-all-errors "${MEVBOOST_URL}"; then
        EXTRA_OPTS="${EXTRA_OPTS} --builder=${MEVBOOST_URL}"
    else
        echo "MEVBOOST is enabled but ${MEVBOOST_URL} is not reachable"
        curl -X POST -G 'http://my.dappnode/notification-send' --data-urlencode 'type=danger' --data-urlencode title="${MEVBOOST_URL} is not available" --data-urlencode 'body=Make sure the mevboost is available and running'
    fi
fi

exec lighthouse \
    --debug-level $DEBUG_LEVEL \
    --network mainnet \
    beacon_node \
    --datadir /root/.lighthouse \
    --http \
    --http-allow-origin "*" \
    --http-address 0.0.0.0 \
    --http-port $BEACON_API_PORT \
    --port $P2P_PORT \
    --metrics \
    --metrics-address 0.0.0.0 \
    --metrics-port 8008 \
    --metrics-allow-origin "*" \
    --execution-endpoint $HTTP_ENGINE \
    --execution-jwt "/jwtsecret" \
    $EXTRA_OPTS
