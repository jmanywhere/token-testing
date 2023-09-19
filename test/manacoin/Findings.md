# ManaCoin - Additional Findings Report

## Function Arguments Checks

- `addReflection` does not check that `msg.value > 0`.
- `claimReflection` uses `!_isContract` which does not assure that the sender is an EOA.

## Best Practices

- `recoverAllEth` should use `call` instead of `transfer` for better gas performances.
- `recoverAllEth` and `recoverErc20token` functions, do not check if the amounts to withdraw and the tokens to withdraw are external to the core functionality of the token and owner can DRAIN the contract of all funds it holds.
- `_getTaxAmount` can be optimized by reducing the amount of outputs to 1 variable. The calculation for all spreads are redudant since they are the same and need only to be calculated once. This reduces readability and increases gas costs.
- `_generateRandomTaxType` is not exclusively random and will behave the exact same way for all transactions made a user in a single block. This is due to the fact that all arguments passed to the `abi.encodePacked` function remain the same block. While this is NOT a vulnerability, it is a bad practice to use this function as a source of randomness.

## Functionality Assessment

- `SafeMath` is implemented even though compiler used is 0.8.18 which already check for over/underflows and reverts the transaction.
- `dxRouter` is not excluded from Fees, so removing liquidity incurs in fees, even while the `msg.sender` is the owner.
- `claimableReflection` mapping is not used except to self set to 0.

## Exploits

- `claimReflection` can be called by different wallets utilizing the same amount of tokens and transferring them between themselves to drain all the ETH from the contract. A simple Factory contract can be used to create multiple wallets and transfer tokens between them while self destructing to fool the `_isContract` check.
