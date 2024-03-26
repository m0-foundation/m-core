#!/usr/bin/env bash
set -e

while getopts p: flag
do
    case "${flag}" in
        p) profile=${OPTARG};;
    esac
done

echo Using epoch profile: $profile

if [ "$profile" = "dry-run" ]; then
    # Dry run has 24 hour epochs
    timestamp=$(date +%s)
    timestamp=$(expr $timestamp - 86401)
    sed -i '' "s/.*constant STARTING_TIMESTAMP.*/    uint40 internal constant STARTING_TIMESTAMP = $timestamp;/" lib/ttg/src/libs/PureEpochs.sol
    sed -i '' "s/.*constant EPOCH_PERIOD.*/    uint40 internal constant EPOCH_PERIOD = 1 days;/" lib/ttg/src/libs/PureEpochs.sol
elif [ "$profile" = "staging" ]; then
    # Staging has 15 minute epochs
    timestamp=$(date +%s)
    timestamp=$(expr $timestamp - 901)
    sed -i '' "s/.*constant STARTING_TIMESTAMP.*/    uint40 internal constant STARTING_TIMESTAMP = $timestamp;/" lib/ttg/src/libs/PureEpochs.sol
    sed -i '' "s/.*constant EPOCH_PERIOD.*/    uint40 internal constant EPOCH_PERIOD = 15 minutes;/" lib/ttg/src/libs/PureEpochs.sol
elif [ "$profile" = "dev" ]; then
    # Dev has 400 second epochs
    timestamp=$(date +%s)
    timestamp=$(expr $timestamp - 401)
    sed -i '' "s/.*constant STARTING_TIMESTAMP.*/    uint40 internal constant STARTING_TIMESTAMP = $timestamp;/" lib/ttg/src/libs/PureEpochs.sol
    sed -i '' "s/.*constant EPOCH_PERIOD.*/    uint40 internal constant EPOCH_PERIOD = 400 seconds;/" lib/ttg/src/libs/PureEpochs.sol
elif [ "$profile" = "test" ]; then
    # Mainnet has 15 day epochs
    sed -i '' "s/.*constant STARTING_TIMESTAMP.*/    uint40 internal constant STARTING_TIMESTAMP = 1_710_171_999;/" lib/ttg/src/libs/PureEpochs.sol
    sed -i '' "s/.*constant EPOCH_PERIOD.*/    uint40 internal constant EPOCH_PERIOD = 15 days;/" lib/ttg/src/libs/PureEpochs.sol
elif [ "$profile" = "production" ]; then
    # Mainnet has 15 day epochs
    timestamp=$(date +%s)
    timestamp=$(expr $timestamp - 1296001)
    sed -i '' "s/.*constant STARTING_TIMESTAMP.*/    uint40 internal constant STARTING_TIMESTAMP = $timestamp;/" lib/ttg/src/libs/PureEpochs.sol
    sed -i '' "s/.*constant EPOCH_PERIOD.*/    uint40 internal constant EPOCH_PERIOD = 15 days;/" lib/ttg/src/libs/PureEpochs.sol
fi
