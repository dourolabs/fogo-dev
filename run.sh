#!/bin/bash

set -e

cleanup() {
    echo "Received SIGINT, shutting down..."
    exit 0
}
trap cleanup SIGINT

trap 'echo "Error on line $LINENO"' ERR

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEDGER_DIR="$WORKSPACE_DIR/ledger"
KEY_DIR="$WORKSPACE_DIR/keys"

FAUCET_KEY="$KEY_DIR/faucet.json"
IDENTITY_KEY="$KEY_DIR/identity.json"
VOTE_KEY="$KEY_DIR/vote.json"
STAKE_KEY="$KEY_DIR/stake.json"

GENESIS_HASHES_PER_TICK=6250
GENESIS_SLOTS_PER_EPOCH=90000
GENESIS_TARGET_TICK_DURATION=625
GENESIS_TICKS_PER_SLOT=64
GENESIS_ACCOUNTS_PATH="$WORKSPACE_DIR/accounts.yaml"

# Delete ledger if it exists
if [ -d "$LEDGER_DIR" ]; then
    rm -rf "$LEDGER_DIR"
    echo "Deleted $LEDGER_DIR"
else
    echo "No existing ledger directory found at $LEDGER_DIR"
fi
echo

# Ensure keys directory exists
if [ ! -d "$KEY_DIR" ]; then
    mkdir -p "$KEY_DIR"
fi

# Create keys if they don't exist
for keyfile in "$FAUCET_KEY" "$IDENTITY_KEY" "$VOTE_KEY" "$STAKE_KEY"; do
    if [ ! -f "$keyfile" ]; then
        solana-keygen new --no-bip39-passphrase --silent --outfile "$keyfile"
    fi
done

echo "Identity: $(solana-keygen pubkey $IDENTITY_KEY)"
echo "Vote: $(solana-keygen pubkey $VOTE_KEY)"
echo "Stake: $(solana-keygen pubkey $STAKE_KEY)"
echo "Faucet: $(solana-keygen pubkey $FAUCET_KEY)"
echo "Ledger: $LEDGER_DIR"
echo

SOL="000000000"
MILLION="000000"

# echo "Initializing ledger..."
# mkdir -p "$LEDGER_DIR"
# solana-genesis \
#     --bootstrap-validator "$IDENTITY_KEY" "$VOTE_KEY" "$STAKE_KEY" \
#     --bootstrap-validator-stake-lamports 10$SOL \
#     --enable-warmup-epochs \
#     --faucet-pubkey "$FAUCET_KEY" \
#     --faucet-lamports 10000$MILLION$SOL \
#     --fee-burn-percentage 100 \
#     --hashes-per-tick "$GENESIS_HASHES_PER_TICK" \
#     --inflation none \
#     --ledger "$LEDGER_DIR" \
#     --primordial-accounts-file "$GENESIS_ACCOUNTS_PATH" \
#     --rent-burn-percentage 100 \
#     --slots-per-epoch "$GENESIS_SLOTS_PER_EPOCH" \
#     --target-tick-duration "$GENESIS_TARGET_TICK_DURATION" \
#     --ticks-per-slot "$GENESIS_TICKS_PER_SLOT"

cp -r $WORKSPACE_DIR/ledger.bkp $WORKSPACE_DIR/ledger

# Initializing ledger...
# Creation time: 2025-04-28T01:34:39+00:00
# Cluster type: MainnetBeta
# Genesis hash: c58C8kyvNu4b2Kovk8JVvCH7KHBJaJGchQryaH86y8c
# Shred version: 31738
# Ticks per slot: 64
# Hashes per tick: Some(6250)
# Target tick duration: 625µs
# Slots per epoch: 90000
# Warmup epochs: enabled
# Slots per year: 788923149.84
# Inflation { initial: 0.0, terminal: 0.0, taper: 0.0, foundation: 0.0, foundation_term: 0.0, __unused: 0.0 }
# Rent { lamports_per_byte_year: 3480, exemption_threshold: 2.0, burn_percent: 100 }
# FeeRateGovernor { lamports_per_signature: 9500, target_lamports_per_signature: 10000, target_signatures_per_slot: 20000, min_lamports_per_signature: 5000, max_lamports_per_signature: 100000, burn_percent: 100 }
# Capitalization: 10500000000 SOL in 615 accounts
# Native instruction processors: []
# Rewards pool: {}

if [ -z "$NO_CONFIGURE" ]; then
    sudo $WORKSPACE_DIR/fogo/build/native/gcc/bin/fdctl configure fini all --config $WORKSPACE_DIR/config.toml
    sudo $WORKSPACE_DIR/fogo/build/native/gcc/bin/fdctl configure init all --config $WORKSPACE_DIR/config.toml
fi

sudo $WORKSPACE_DIR/fogo/build/native/gcc/bin/fdctl run --config $WORKSPACE_DIR/config.toml | grep -v metrics.rs
