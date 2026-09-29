# RPC Providers & Web3 Application Architecture

This milestone expanded my understanding from deploying and interacting
with smart contracts to understanding the infrastructure that connects a
Web3 application to a blockchain.

The main idea is that a smart contract lives on the blockchain, while
applications need a way to communicate with the blockchain. RPC
infrastructure provides that communication path.

------------------------------------------------------------------------

## 1. The Problem RPC Solves

A blockchain network contains nodes that maintain and expose access to
blockchain state.

My application cannot simply "talk to the blockchain" as if the
blockchain were a normal database. It needs a communication interface.

That interface is commonly provided through **RPC (Remote Procedure
Call)**.

``` text
Application
     ↓
   RPC
     ↓
Blockchain Node
     ↓
Blockchain
```

An RPC endpoint is therefore a communication endpoint through which
software can request blockchain data or submit transactions.

------------------------------------------------------------------------

## 2. What a Blockchain Node Does

A blockchain node is software that participates in or provides access to
a blockchain network.

A node can receive blockchain requests, read blockchain state, submit
transactions to the network, and expose interfaces such as JSON-RPC for
applications and developer tools.

A useful distinction is:

> The node does not "host my smart contract" in the same way that a web
> server hosts a website.

The smart contract is deployed to the blockchain. The node provides
access to the blockchain where that contract exists.

``` text
Smart Contract
      ↓
Lives as blockchain state
      ↓
Blockchain network
      ↓
Node / RPC interface
      ↓
Application
```

------------------------------------------------------------------------

## 3. RPC as the Communication Layer

When I use Foundry commands such as:

``` bash
forge script ...
```

or:

``` bash
cast call ...
```

Foundry needs to know which blockchain network it should communicate
with.

That is why commands commonly contain:

``` bash
--rpc-url
```

For example:

``` bash
forge script script/DeploySimpleStorage.s.sol     --rpc-url sepolia
```

The RPC URL tells Foundry where to send its blockchain requests.

``` text
Foundry
   ↓
RPC endpoint
   ↓
Node infrastructure
   ↓
Blockchain network
```

This is the same fundamental idea whether the RPC infrastructure belongs
to me or is provided by a service such as Alchemy.

------------------------------------------------------------------------

## 4. Running My Own Node vs Using an RPC Provider

There are two broad approaches.

### Run my own node

``` text
My application
      ↓
My RPC interface
      ↓
My blockchain node
      ↓
Blockchain network
```

This gives me more direct control, but I become responsible for
hardware, storage, networking, synchronization, uptime, maintenance,
monitoring, and updates.

### Use an RPC provider

``` text
My application
      ↓
RPC provider
      ↓
Provider's node infrastructure
      ↓
Blockchain network
```

The provider operates the infrastructure and exposes an RPC endpoint
that my application can use.

This lets me focus more on building the application instead of operating
blockchain nodes myself.

------------------------------------------------------------------------

## 5. What Alchemy Is

Alchemy is primarily **blockchain infrastructure and developer
tooling**.

A useful mental model is:

> Alchemy provides managed blockchain-node/RPC infrastructure and
> additional APIs and developer services.

For example:

``` text
My Foundry project
       ↓
Alchemy RPC
       ↓
Ethereum / ZKsync / another supported network
```

Alchemy can provide the endpoint through which my development tools or
application communicate with the blockchain.

It can also provide additional APIs, SDKs, monitoring, and
developer-oriented infrastructure.

The important point is that Alchemy is not the blockchain itself.

------------------------------------------------------------------------

## 6. Alchemy Is Not Etherscan

These two services solve different problems.

### Alchemy

``` text
Application / Developer
          ↓
       Alchemy
          ↓
      Blockchain
```

Alchemy provides infrastructure and APIs for applications to communicate
with blockchain networks.

### Etherscan

``` text
Blockchain
     ↓
Etherscan
     ↓
Human-readable explorer
```

Etherscan is a blockchain explorer useful for inspecting transactions,
blocks, contract addresses, balances, events, verified source code, and
transaction information.

A simple distinction:

> **Alchemy helps my software communicate with the blockchain.**

> **Etherscan helps me inspect what is happening on the blockchain.**

------------------------------------------------------------------------

## 7. Wallet vs RPC Provider

These two concepts have completely different responsibilities.

### Wallet / private key

The private key is used to authorize a transaction by signing it.

``` text
Private Key
     ↓
Signs transaction
     ↓
Signed transaction
```

The public wallet address identifies the account.

### RPC provider

The RPC provider provides the communication path through which the
signed transaction can be sent to the blockchain.

``` text
Private Key
     ↓
Signs transaction
     ↓
Signed transaction
     ↓
RPC provider
     ↓
Blockchain
```

The RPC provider does **not** need my private key merely because it
provides RPC access.

I should never give an RPC provider my private key just to use its RPC
endpoint.

------------------------------------------------------------------------

## 8. Contract Address, ABI, and Bytecode

These three pieces of information have different jobs.

### Contract address

The contract address identifies the particular deployed contract on a
particular blockchain network.

It answers:

> Which deployed contract am I trying to interact with?

### ABI

The ABI describes the contract's callable interface.

It tells application software about function names, parameters, return
values, events, and mutability.

It answers:

> How do I communicate with this contract?

### Bytecode

Bytecode is the compiled machine-readable code produced from the
Solidity source. It is used when deploying the contract.

It answers:

> What code should be deployed to the blockchain?

``` text
Solidity source
      ↓
    Compiler
      ↓
 ┌────┴─────┐
 ↓          ↓
Bytecode    ABI
 ↓
Deployment
 ↓
Contract address
```

After deployment, an application commonly needs:

``` text
Contract Address + ABI
```

to interact with the deployed contract.

------------------------------------------------------------------------

## 9. Deployment Flow

A simplified deployment lifecycle is:

``` text
Write Solidity contract
        ↓
Compile with Foundry
        ↓
Generate bytecode + ABI
        ↓
Choose blockchain network
        ↓
Choose wallet/account
        ↓
Choose RPC endpoint
        ↓
Create deployment transaction
        ↓
Sign transaction
        ↓
Send through RPC
        ↓
Blockchain processes transaction
        ↓
Contract deployed
        ↓
Receive contract address
```

The RPC provider is the communication infrastructure. The blockchain is
where the contract is actually deployed.

------------------------------------------------------------------------

## 10. Application Read Flow

Reading blockchain state does not normally require a state-changing
transaction.

For example:

``` solidity
function retrieve() public view returns (uint256) {
    return favoriteNumber;
}
```

The application can request that value through an RPC endpoint.

``` text
Frontend
   ↓
RPC provider
   ↓
Blockchain
   ↓
Smart contract state
   ↓
RPC response
   ↓
Frontend
```

A read-only call does not require the user to sign a transaction.

------------------------------------------------------------------------

## 11. Application Write Flow

Writing to the blockchain is different. If the user wants to change
contract state, the transaction needs authorization.

``` text
User
 ↓
Frontend
 ↓
Wallet
 ↓
User signs transaction
 ↓
Signed transaction
 ↓
RPC provider
 ↓
Blockchain
 ↓
Smart contract
 ↓
State changes
```

The RPC provider transports the request.

The wallet provides authorization.

The blockchain executes the transaction.

The smart contract contains the logic.

------------------------------------------------------------------------

## 12. Where the Smart Contract Actually Lives

One of the most important corrections to my earlier mental model is:

> My smart contract does not live "inside Alchemy."

It also does not live inside Foundry, MetaMask, Etherscan, my frontend,
or my RPC provider.

After deployment, the contract becomes part of the state of the
blockchain network to which it was deployed.

``` text
My Solidity project
        ↓
Foundry compiles it
        ↓
Deployment transaction
        ↓
Ethereum / ZKsync / another network
        ↓
Contract exists on that blockchain
```

Alchemy or another RPC provider gives my software a way to communicate
with that network.

------------------------------------------------------------------------

## 13. What Alchemy Does Not Do

Using an RPC provider does not mean the provider becomes the owner of my
application.

Alchemy does not replace my frontend, backend, smart contract, wallet,
blockchain network, or application's business logic.

It also does not mean I upload my Solidity project to Alchemy and have
Alchemy "host the contract."

``` text
My Application
     │
     ├── Frontend
     ├── Backend
     └── Smart-contract code
              │
              ↓
        Blockchain network
              ↑
              │
        RPC infrastructure
              │
           Alchemy
```

My website can be hosted somewhere completely different from the
blockchain and RPC infrastructure.

------------------------------------------------------------------------

## 14. Complete Web3 Application Architecture

A more complete architecture looks like:

``` text
                         USER
                           │
                           ↓
                  ┌─────────────────┐
                  │   Web / Mobile  │
                  │      App        │
                  └────────┬────────┘
                           │
              ┌────────────┴────────────┐
              ↓                         ↓
       Read blockchain            Write request
              │                         │
              ↓                         ↓
        RPC provider                 Wallet
        (e.g. Alchemy)                 │
              │                    User signs
              │                         │
              └────────────┬────────────┘
                           ↓
                    RPC / Node layer
                           ↓
                  Blockchain network
                           ↓
                    Smart contract
                           ↓
                    Contract state
```

This gives me a clear division of responsibility:

  -----------------------------------------------------------------------
  Component                           Main responsibility
  ----------------------------------- -----------------------------------
  Frontend                            User interface and application
                                      interaction

  Backend                             Application/business logic where
                                      needed

  Wallet                              Holds keys and signs
                                      user-authorized transactions

  RPC provider                        Communication access to blockchain
                                      infrastructure

  Blockchain node                     Provides access to/processes
                                      blockchain data and transactions
                                      depending on its role

  Blockchain                          Stores and executes network state

  Smart contract                      Enforces on-chain program logic

  Contract address                    Identifies a deployed contract

  ABI                                 Describes how software communicates
                                      with the contract

  Bytecode                            Compiled code used for deployment

  Etherscan                           Human-readable blockchain explorer
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## 15. The Complete Mental Model

The most useful mental model from this lesson is:

``` text
                  WEB3 APPLICATION

User
 ↓
Frontend / Backend
 ↓
 ┌──────────────────────────────┐
 │                              │
 │  Read              Write     │
 │   ↓                  ↓       │
 │  RPC              Wallet     │
 │   ↓                  ↓       │
 │  └──────────┬───────────────┘
 │             ↓
 │        RPC / Node
 │             ↓
 │       Blockchain
 │             ↓
 │      Smart Contract
 │             ↓
 │       Contract State
 │
 └──────────────────────────────┘
```

The key idea is that these are **different layers**, even though they
work together.

------------------------------------------------------------------------

## 16. What This Lesson Added to My Mental Model

### Before

My understanding was mostly:

``` text
My contract
    ↓
Deploy it
    ↓
Blockchain
```

I understood how to deploy and interact with contracts, but I had not
fully understood the infrastructure between my application and the
blockchain.

### After

My mental model is now:

``` text
Application
     ↓
Wallet / RPC
     ↓
Node infrastructure
     ↓
Blockchain
     ↓
Smart contract
```

I understand that I have choices about the infrastructure layer:

1.  operate my own node infrastructure, or
2.  use an RPC provider such as Alchemy.

The important distinction is:

> **The blockchain stores and executes the smart contract. The RPC/node
> layer provides the communication path that lets my software access the
> blockchain.**

------------------------------------------------------------------------

## Key Takeaways

1.  **RPC** is a communication interface used by applications and
    developer tools to interact with blockchain infrastructure.
2.  A **blockchain node** provides access to blockchain data and
    participates in network operations depending on its role.
3.  An **RPC provider** can operate node infrastructure on my behalf.
4.  **Alchemy** is primarily blockchain infrastructure and developer
    tooling, not a blockchain itself.
5.  **Etherscan** is a blockchain explorer, while Alchemy provides
    infrastructure/APIs for software.
6.  A **private key signs transactions**; an RPC provider does not
    replace the wallet.
7.  A **contract address identifies a deployed contract**.
8.  An **ABI describes how software communicates with that contract**.
9.  **Bytecode is compiled contract code used during deployment**.
10. The **smart contract lives on the blockchain**, not inside Alchemy
    or Foundry.
11. A frontend can read blockchain state through RPC infrastructure
    without requiring the user to sign a transaction.
12. State-changing writes normally require a wallet to sign a
    transaction.
13. The application can be hosted separately from the blockchain and RPC
    infrastructure.
14. A Web3 application is therefore a collection of layers working
    together rather than one system where everything lives in the same
    place.

------------------------------------------------------------------------

## Next Concept to Explore

The next useful step is to take this architecture and actually connect
it to a deployed contract.

That means understanding exactly how:

``` text
Contract Address
        +
ABI
        +
RPC Provider
        +
Wallet
        ↓
Application
        ↓
Smart Contract
```

becomes actual application code that can read from and write to a
deployed contract.
