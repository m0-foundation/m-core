# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

profile ?=default

# Coverage report
coverage:
	./set-epochs.sh -p test && FOUNDRY_PROFILE=$(profile) forge coverage --rpc-url $(MAINNET_RPC_URL) --no-match-path 'test/invariant/**/*.sol' --report lcov && lcov --extract lcov.info -o lcov.info 'src/*' && genhtml lcov.info -o coverage

coverage-summary:
	./set-epochs.sh -p test && FOUNDRY_PROFILE=$(profile) forge coverage --rpc-url $(MAINNET_RPC_URL) --no-match-path 'test/invariant/**/*.sol' --report summary

# Deployment helpers
deploy-dry-run:
	./set-epochs.sh -p dry-run && forge script script/DeployDryRun.s.sol --skip src --skip test --rpc-url $(SEPOLIA_RPC_URL) --broadcast --slow --verify -vvv

deploy-staging:
	./set-epochs.sh -p staging && forge script script/DeployDev.s.sol --skip src --skip test --rpc-url $(SEPOLIA_RPC_URL) --broadcast --slow --verify -vvv

deploy-dev:
	./set-epochs.sh -p dev && forge script script/DeployDev.s.sol --skip src --skip test --rpc-url $(SEPOLIA_RPC_URL) --broadcast --slow --verify -vvv

deploy-production:
	./set-epochs.sh -p production && forge script script/DeployProduction.s.sol --skip src --skip test --rpc-url $(MAINNET_RPC_URL) --broadcast --slow --verify -vvv

sync-production:
	forge script script/SyncAccounts.s.sol --skip src --skip test --rpc-url $(MAINNET_RPC_URL) --broadcast --slow --verify -vvv

deploy-local:
	./set-epochs.sh -p dev && forge script script/DeployDev.s.sol --skip src --skip test --rpc-url $(LOCALHOST_RPC_URL) --broadcast --slow -vvv

deploy-fork:
	./set-epochs.sh -p production && FOUNDRY_PROFILE=fork forge script script/DeployProduction.s.sol --skip src --skip test --rpc-url $(LOCALHOST_RPC_URL) --broadcast --slow -vvv

# Run slither
slither:
	./set-epochs.sh -p production && FOUNDRY_PROFILE=production forge build --build-info --skip '*/test/**' --skip '*/script/**' --force && slither --compile-force-framework foundry --ignore-compile --sarif results.sarif --config-file slither.config.json .

# Common tasks
update:
	forge update

build:
	./set-epochs.sh -p production && ./build.sh

tests:
	./set-epochs.sh -p test && RPC_URL=$(MAINNET_RPC_URL) ./test.sh -p $(profile)

test-match:
	./set-epochs.sh -p test && RPC_URL=$(MAINNET_RPC_URL) ./test.sh -t $(match) -p $(profile) -v

fuzz:
	./set-epochs.sh -p test && RPC_URL=$(MAINNET_RPC_URL) ./test.sh -t testFuzz -p $(profile)

integration:
	./set-epochs.sh -p test && RPC_URL=$(MAINNET_RPC_URL) ./test.sh -d test/integration -p $(profile)

invariant:
	./set-epochs.sh -p test && RPC_URL=$(MAINNET_RPC_URL) ./test.sh -d test/invariant -p $(profile)

gas-report:
	./set-epochs.sh -p test && forge test --no-match-path 'test/invariant/*' --gas-report > gasreport.ansi

gas-report-hardhat:
	./set-epochs.sh -p production && npx hardhat test

sizes:
	./set-epochs.sh -p production && ./build.sh -s

clean:
	forge clean
