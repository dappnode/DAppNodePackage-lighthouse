#!/bin/bash

NETWORK="mainnet"
VALIDATOR_PORT=3500

# MEVBOOST: https://lighthouse-book.sigmaprime.io/builders.html
if [ -n "$_DAPPNODE_GLOBAL_MEVBOOST_MAINNET" ] && [ "$_DAPPNODE_GLOBAL_MEVBOOST_MAINNET" == "true" ]; then
    echo "MEVBOOST is enabled"
    MEVBOOST_URL="http://mev-boost.mev-boost.dappnode:18550"
    EXTRA_OPTS="--builder-proposals ${EXTRA_OPTS}"
fi

# Chek the env FEE_RECIPIENT_MAINNET has a valid ethereum address if not set to the null address
if [ -n "$FEE_RECIPIENT_MAINNET" ] && [[ "$FEE_RECIPIENT_MAINNET" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
    FEE_RECIPIENT_ADDRESS="$FEE_RECIPIENT_MAINNET"
else
    echo "FEE_RECIPIENT_MAINNET is not set or is not a valid ethereum address, setting it to the null address"
    FEE_RECIPIENT_ADDRESS="0x0000000000000000000000000000000000000000"
fi

oLang=$LANG oLcAll=$LC_ALL
LANG=C LC_ALL=C 
graffitiString=${GRAFFITI:0:32}
LANG=$oLang LC_ALL=$oLcAll

exec -c lighthouse \
    --debug-level=${DEBUG_LEVEL} \
    --network=${NETWORK} \
    validator \
    --enable-doppelganger-protection \
    --init-slashing-protection \
    --datadir /root/.lighthouse \
    --beacon-nodes $BEACON_NODE_ADDR \
    --graffiti="${graffitiString}" \
    --http \
    --http-address 0.0.0.0 \
    --http-port ${VALIDATOR_PORT} \
    --http-allow-origin "*" \
    --unencrypted-http-transport \
    --metrics \
    --metrics-address 0.0.0.0 \
    --metrics-port 8008 \
    --metrics-allow-origin "*" \
    --suggested-fee-recipient="${FEE_RECIPIENT_ADDRESS}" \
    $EXTRA_OPTS
