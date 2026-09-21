# 03 — Interacting With Smart Contracts, Sepolia Deployment & Etherscan

## Overview

This session moved from working with a local Anvil blockchain to interacting with a public Ethereum testnet. The main goal was to understand how Foundry can communicate with a deployed smart contract without relying on a GUI such as Remix.

We covered:
- `cast send` for state-changing transactions
- `cast call` for read-only contract interactions
- Using `retrieve()` to read contract state
- Using a Node-as-a-Service provider to obtain an RPC endpoint
- Connecting Foundry to Ethereum Sepolia
- Using a wallet to authorize deployment
- Inspecting transactions and contracts with Etherscan

---

## 1. Interacting With a Contract From the Command Line

Remix provides a graphical interface for interacting with deployed contracts. Foundry exposes the same underlying operations more directly through the command line.

### Writing — `cast send`

A state-changing function can be called with:

```bash
cast send <CONTRACT_ADDRESS> "store(uint256)" 42
```

Conceptually:

```text
Your wallet
    ↓
Transaction
    ↓
Contract address
    ↓
store(42)
    ↓
Blockchain state changes
```

Because this changes state, a transaction is required, the wallet must authorize it, and gas is required.

### Reading — `cast call`

For a read-only function:

```bash
cast call <CONTRACT_ADDRESS> "retrieve()"
```

Conceptually:

```text
You
 ↓
RPC
 ↓
Contract
 ↓
retrieve()
 ↓
Current blockchain state
```

No state-changing transaction is created and no gas is paid for this read.

This is essentially what Remix was doing when we clicked a read function such as `retrieve`.

---

## 2. `retrieve()` and the `view` Function

A typical SimpleStorage function looks like:

```solidity
function retrieve() public view returns (uint256) {
    return favoriteNumber;
}
```

The `view` keyword tells Solidity that the function can read blockchain state but does not modify it.

```text
store(...)
   ↓
changes state
   ↓
transaction required
   ↓
cast send

retrieve()
   ↓
reads state
   ↓
no state-changing transaction
   ↓
cast call
```

---

## 3. Moving From Anvil to a Public Testnet

Earlier, the project used Anvil:

```text
Foundry
   ↓
Anvil
   ↓
Local blockchain
```

This lesson moved to Ethereum Sepolia:

```text
Foundry
   ↓
RPC endpoint
   ↓
Ethereum Sepolia
   ↓
Public test blockchain
```

**Ethereum Sepolia is an Ethereum testnet, not Ethereum Mainnet.**

The ETH used on Sepolia is test ETH intended for development and testing.

---

## 4. Node-as-a-Service

Instead of running our own Ethereum infrastructure, we used a Node-as-a-Service provider to obtain an RPC endpoint.

The provider's infrastructure gives our tools a way to communicate with the selected blockchain network.

```text
Your computer
      ↓
Foundry / Cast
      ↓
RPC endpoint
      ↓
Node infrastructure
      ↓
Ethereum Sepolia
```

The provider is not the blockchain itself. It provides access to node infrastructure.

---

## 5. Configuring the Sepolia RPC

The RPC endpoint can be stored in `.env`:

```env
SEPOLIA_RPC_URL=...
```

Then `foundry.toml` can provide an alias:

```toml
[rpc_endpoints]
sepolia = "${SEPOLIA_RPC_URL}"
```

This lets Foundry use:

```bash
forge script ... --rpc-url sepolia
```

instead of repeatedly typing the full endpoint.

---

## 6. Wallet Authentication

Deploying to Sepolia requires a wallet to authorize the transaction.

### Private key

The private key authorizes transactions and must remain secret.

### Public address

The public address identifies the wallet on-chain and can be shared publicly.

```text
Private key
     ↓
Signs transaction
     ↓
Blockchain verifies signature
     ↓
Transaction accepted
```

This connects directly to the previous wallet-security lesson. A `.env` file can prevent accidental Git exposure when properly ignored, but storing a private key there still means the key is plaintext at rest. The encrypted Cast keystore workflow from the previous lesson provides stronger protection for the key itself.

---

## 7. Local Anvil vs Ethereum Sepolia

Foundry can interact with different blockchain environments through different RPC endpoints.

### Local development

```text
Forge
 ↓
Anvil
 ↓
Chain ID 31337
 ↓
Local blockchain
```

### Public testnet

```text
Forge
 ↓
Sepolia RPC
 ↓
Ethereum Sepolia
 ↓
Chain ID 11155111
 ↓
Public testnet
```

The Solidity contract does not fundamentally change just because the RPC endpoint changed. The blockchain environment that Foundry communicates with has changed.

---

## 8. Etherscan — Inspecting What Happened On-Chain

After broadcasting a transaction to Sepolia, Etherscan can be used to inspect the transaction and deployed contract.

A transaction hash can be used to inspect:
- Whether the transaction succeeded
- The sender
- The destination contract
- The block containing the transaction
- Gas information
- Transaction input data
- Events emitted by the contract

The deployed contract address can also be inspected.

Once a contract is verified, Etherscan can provide a human-readable interface to the contract's source and ABI-derived functions.

This gives us an independent way to inspect what exists on the public blockchain instead of relying only on Foundry's output.

---

## 9. The Complete Development Loop

```text
Write Solidity
      ↓
Compile with Foundry
      ↓
Deploy / interact with Foundry
      ↓
RPC endpoint
      ↓
Ethereum Sepolia
      ↓
Transaction
      ↓
Etherscan
      ↓
Inspect / verify
      ↓
cast call
      ↓
Read contract state
```

This is an important progression from using Remix. Remix gave us a graphical interface over many of these operations, while Foundry exposes the underlying mechanisms more directly.

---

## Key Takeaways

1. `cast send` is used to submit state-changing contract transactions.
2. `cast call` is used to perform read-only contract calls.
3. A `view` function such as `retrieve()` reads blockchain state without creating a state-changing transaction.
4. An RPC endpoint is the connection through which Foundry communicates with blockchain node infrastructure.
5. A Node-as-a-Service provider can provide that infrastructure without us running the node ourselves.
6. Ethereum Sepolia is a public Ethereum testnet, not Ethereum Mainnet.
7. The private key authorizes transactions; the public address identifies the wallet.
8. Etherscan allows us to independently inspect transactions and deployed contracts on the public chain.
9. Moving from Anvil to Sepolia changes the blockchain environment, not the fundamental Solidity contract interaction model.
10. The command line is not doing something fundamentally different from Remix — it is exposing the underlying blockchain interaction more directly.

---

## What This Lesson Added To My Mental Model

Before:

> "I deploy a contract and interact with it through Remix."

After:

> "My tools communicate with a blockchain through an RPC endpoint. I can submit signed transactions with `cast send`, read state with `cast call`, and independently inspect the resulting transactions and contracts on a blockchain explorer such as Etherscan."

That is the main conceptual milestone from this lesson.
