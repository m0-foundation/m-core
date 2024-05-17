# M^0 Core

## Deploy

### Staging deploy

Run the following command to deploy the contracts to Sepolia:

```bash
make deploy-staging
```

### Production deploy

Run the following command to deploy the contracts to Ethereum Mainnet:

```bash
make deploy-production
```

## Tests

### Integration and unit tests

Run:

```bash
make tests
```

### Fork tests

To run the local fork tests in one command, run:

```bash
yarn fork-run:local
```
