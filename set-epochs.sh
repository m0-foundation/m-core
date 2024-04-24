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
    period="1 days"
elif [ "$profile" = "staging" ]; then
    # Staging has 15 minute epochs
    timestamp=$(date +%s)
    timestamp=$(expr $timestamp - 901)
    period="15 minutes"
elif [ "$profile" = "dev" ]; then
    # Dev has 400 second epochs
    timestamp=$(date +%s)
    timestamp=$(expr $timestamp - 401)
    period="400 seconds"
elif [ "$profile" = "test" ]; then
    # Mainnet has 15 day epochs
    timestamp="1_710_171_999"
    period="15 days"
elif [ "$profile" = "production" ]; then
    # Mainnet has 15 day epochs
    timestamp=$(date +%s)
    timestamp=$(expr $timestamp - 1296001)
    period="15 days"
fi

sed "s/.*constant STARTING_TIMESTAMP.*/    uint40 internal constant STARTING_TIMESTAMP = $timestamp;/" lib/ttg/src/libs/PureEpochs.sol > ./lib/ttg/src/libs/PureEpochs1.sol
sed "s/.*constant EPOCH_PERIOD.*/    uint40 internal constant EPOCH_PERIOD = $period;/" lib/ttg/src/libs/PureEpochs.sol > ./lib/ttg/src/libs/PureEpochs2.sol
mv ./lib/ttg/src/libs/PureEpochs2.sol ./lib/ttg/src/libs/PureEpochs.sol
rm ./lib/ttg/src/libs/PureEpochs1.sol
