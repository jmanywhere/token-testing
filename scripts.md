# Scripts to help test

## Test with ETH MAINNET FORK

#### General Test everything

`forge test --fork-url $MAINNET_FORK_URL`

#### Usual pattern specific test

`forge test --match-test metadata --fork-url $MAINNET_FORK_URL`

#### Metadata Test

`forge test --match-contract MetadataTest --fork-url $MAINNET_FORK_URL`
