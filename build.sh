#!/usr/bin/env bash
set -e

sizes=false

while getopts s flag
do
    case "${flag}" in
        s) sizes=true;;
    esac
done

export FOUNDRY_PROFILE=production

echo Sizes: $sizes

if [ "$sizes" = false ];
then
    forge build --skip '*/test/**/*.sol' --skip '*/lib/forge-std/**' --extra-output-files abi;
else
    forge build --skip '*/test/**/*.sol' --skip '*/lib/forge-std/**' --extra-output-files abi --sizes;
fi

mkdir -p abi

jq '.abi' ./out/EmergencyGovernor.sol/EmergencyGovernor.json > ./abi/EmergencyGovernor.json
jq '.abi' ./out/EmergencyGovernorDeployer.sol/EmergencyGovernorDeployer.json > ./abi/EmergencyGovernorDeployer.json
jq '.abi' ./out/StandardGovernor.sol/StandardGovernor.json > ./abi/StandardGovernor.json
jq '.abi' ./out/StandardGovernorDeployer.sol/StandardGovernorDeployer.json > ./abi/StandardGovernorDeployer.json
jq '.abi' ./out/ZeroGovernor.sol/ZeroGovernor.json > ./abi/ZeroGovernor.json
jq '.abi' ./out/PowerBootstrapToken.sol/PowerBootstrapToken.json > ./abi/PowerBootstrapToken.json
jq '.abi' ./out/PowerToken.sol/PowerToken.json > ./abi/PowerToken.json
jq '.abi' ./out/PowerTokenDeployer.sol/PowerTokenDeployer.json > ./abi/PowerTokenDeployer.json
jq '.abi' ./out/Registrar.sol/Registrar.json > ./abi/Registrar.json
jq '.abi' ./out/ZeroToken.sol/ZeroToken.json > ./abi/ZeroToken.json
jq '.abi' ./out/DistributionVault.sol/DistributionVault.json > ./abi/DistributionVault.json
jq '.abi' ./out/MockToken.sol/MockToken.json > ./abi/MockToken.json

jq '.abi' ./out/MinterGateway.sol/MinterGateway.json > ./abi/MinterGateway.json
jq '.abi' ./out/MToken.sol/MToken.json > ./abi/MToken.json
jq '.abi' ./out/MinterRateModel.sol/MinterRateModel.json > ./abi/MinterRateModel.json
jq '.abi' ./out/EarnerRateModel.sol/EarnerRateModel.json > ./abi/EarnerRateModel.json

mkdir -p bytecode

EmergencyGovernorBytecode=$(jq '.bytecode.object' ./out/EmergencyGovernor.sol/EmergencyGovernor.json)
EmergencyGovernorDeployerBytecode=$(jq '.bytecode.object' ./out/EmergencyGovernorDeployer.sol/EmergencyGovernorDeployer.json)
StandardGovernorBytecode=$(jq '.bytecode.object' ./out/StandardGovernor.sol/StandardGovernor.json)
StandardGovernorDeployerBytecode=$(jq '.bytecode.object' ./out/StandardGovernorDeployer.sol/StandardGovernorDeployer.json)
ZeroGovernorBytecode=$(jq '.bytecode.object' ./out/ZeroGovernor.sol/ZeroGovernor.json)
PowerBootstrapTokenBytecode=$(jq '.bytecode.object' ./out/PowerBootstrapToken.sol/PowerBootstrapToken.json)
PowerTokenBytecode=$(jq '.bytecode.object' ./out/PowerToken.sol/PowerToken.json)
PowerTokenDeployerBytecode=$(jq '.bytecode.object' ./out/PowerTokenDeployer.sol/PowerTokenDeployer.json)
RegistrarBytecode=$(jq '.bytecode.object' ./out/Registrar.sol/Registrar.json)
ZeroTokenBytecode=$(jq '.bytecode.object' ./out/ZeroToken.sol/ZeroToken.json)
DistributionVaultBytecode=$(jq '.bytecode.object' ./out/DistributionVault.sol/DistributionVault.json)
MockTokenBytecode=$(jq '.bytecode.object' ./out/MockToken.sol/MockToken.json)

MinterGatewayBytecode=$(jq '.bytecode.object' ./out/MinterGateway.sol/MinterGateway.json)
MTokenBytecode=$(jq '.bytecode.object' ./out/MToken.sol/MToken.json)
MinterRateModelBytecode=$(jq '.bytecode.object' ./out/MinterRateModel.sol/MinterRateModel.json)
EarnerRateModelBytecode=$(jq '.bytecode.object' ./out/EarnerRateModel.sol/EarnerRateModel.json)

echo "{ \"bytecode\": ${EmergencyGovernorBytecode} }" >./bytecode/EmergencyGovernor.json
echo "{ \"bytecode\": ${EmergencyGovernorDeployerBytecode} }" >./bytecode/EmergencyGovernorDeployer.json
echo "{ \"bytecode\": ${StandardGovernorBytecode} }" >./bytecode/StandardGovernor.json
echo "{ \"bytecode\": ${StandardGovernorDeployerBytecode} }" >./bytecode/StandardGovernorDeployer.json
echo "{ \"bytecode\": ${ZeroGovernorBytecode} }" >./bytecode/ZeroGovernor.json
echo "{ \"bytecode\": ${PowerBootstrapTokenBytecode} }" >./bytecode/PowerBootstrapToken.json
echo "{ \"bytecode\": ${PowerTokenBytecode} }" >./bytecode/PowerToken.json
echo "{ \"bytecode\": ${PowerTokenDeployerBytecode} }" >./bytecode/PowerTokenDeployer.json
echo "{ \"bytecode\": ${RegistrarBytecode} }" >./bytecode/Registrar.json
echo "{ \"bytecode\": ${ZeroTokenBytecode} }" >./bytecode/ZeroToken.json
echo "{ \"bytecode\": ${DistributionVaultBytecode} }" >./bytecode/DistributionVault.json
echo "{ \"bytecode\": ${MockTokenBytecode} }" >./bytecode/MockToken.json

echo "{ \"bytecode\": ${MinterGatewayBytecode} }" >./bytecode/MinterGateway.json
echo "{ \"bytecode\": ${MTokenBytecode} }" >./bytecode/MToken.json
echo "{ \"bytecode\": ${MinterRateModelBytecode} }" >./bytecode/MinterRateModel.json
echo "{ \"bytecode\": ${EarnerRateModelBytecode} }" >./bytecode/EarnerRateModel.json
