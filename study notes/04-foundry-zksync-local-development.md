# 04 — Foundry-ZKsync & Local ZKsync Development

## Overview

This session introduced ZKsync-specific development using the Foundry-ZKsync toolchain.

The important idea is not that we are abandoning Foundry. Matter Labs maintains a ZKsync-compatible fork/extension of Foundry so familiar Foundry workflows can target the ZKsync environment.

We covered:

- What Foundry-ZKsync is
- What a software fork means
- `forge build --zksync`
- `anvil-zksync`
- Moving from ordinary Anvil to a local ZKsync development environment
- The distinction between the Solidity project and the installed development tools

---

## 1. What Is Foundry-ZKsync?

Foundry is a development toolchain containing tools such as:

```text
Foundry
│
├── forge
├── cast
├── anvil
└── chisel
```

Foundry-ZKsync is a ZKsync-compatible fork/extension of this toolchain maintained by Matter Labs.

A software fork means that an existing project's source code is taken as a starting point and developed into another version with additional or modified functionality.

```text
Original Foundry
      │
      │ fork / extend
      ↓
Foundry-ZKsync
      │
      ├── ZKsync-aware forge
      ├── ZKsync-aware cast
      └── anvil-zksync
```

ZKsync itself is the blockchain/L2 ecosystem. Foundry-ZKsync is development tooling designed to work with it.

So the better mental model is:

> "ZKsync-compatible Foundry"

rather than:

> "ZKsync is simply the name of another Foundry version."

---

## 2. Why Use a ZKsync Version of Foundry?

Normal Foundry is designed primarily around Ethereum/EVM development.

ZKsync has additional requirements and tooling because it is a different execution environment built as an Ethereum Layer-2.

Therefore, the development tools need ZKsync-specific support.

The practical idea is:

```text
Normal Ethereum-oriented development
        ↓
Normal Foundry

ZKsync development
        ↓
Foundry-ZKsync
```

The deeper differences become more meaningful as we use more ZKsync-specific features later in the course.

---

## 3. `forge build --zksync`

Previously, the project was built with:

```bash
forge build
```

The ZKsync build uses:

```bash
forge build --zksync
```

The `--zksync` flag tells the Foundry-ZKsync toolchain that the project should be compiled for the ZKsync environment.

Conceptually:

```text
SimpleStorage.sol
       ↓
forge build
       ↓
Normal Foundry build
```

versus:

```text
SimpleStorage.sol
       ↓
forge build --zksync
       ↓
ZKsync-compatible build
```

---

## 4. Installing the ZKsync Tooling

The current installation method introduced in the lesson is:

```bash
curl -L https://raw.githubusercontent.com/matter-labs/foundry-zksync/main/install-foundry-zksync | bash
```

This installs the ZKsync Foundry tooling into the user's Foundry tool environment.

The installation does **not** mean that the ZKsync source repository has been cloned into the Solidity project.

The project and the tools are separate:

```text
/home/user/
│
├── .foundry/
│   └── bin/
│       ├── forge
│       ├── cast
│       ├── anvil
│       └── foundryup-zksync
│
└── first-Foundry-Simple-Storage/
    ├── src/
    ├── script/
    ├── test/
    └── foundry.toml
```

The Solidity project is the thing being developed.

The Foundry binaries are the tools used to develop it.

---

## 5. Project Directory vs Tool Directory

Being inside:

```bash
/home/user/first-Foundry-Simple-Storage
```

when running the installer does not mean that the installer was installed into the project directory.

The installer places tooling in the user's Foundry installation directory.

For example:

```bash
which forge
```

returned:

```text
/home/user/.foundry/bin/forge
```

and:

```bash
which foundryup-zksync
```

returned:

```text
/home/user/.foundry/bin/foundryup-zksync
```

This demonstrates that the project and the installed tools are separate.

You normally remain inside your project directory and run commands such as:

```bash
forge build --zksync
```

The shell finds the `forge` executable through the system `PATH`.

---

## 6. `anvil-zksync`

Ordinary Foundry development used:

```bash
anvil
```

to create a local Ethereum-like development blockchain.

The ZKsync workflow introduces:

```bash
anvil-zksync
```

This provides a local ZKsync-oriented development environment.

The comparison is:

```text
Normal Foundry:

Solidity
   ↓
forge
   ↓
anvil
   ↓
Local blockchain
```

and:

```text
Foundry-ZKsync:

Solidity
   ↓
forge --zksync
   ↓
anvil-zksync
   ↓
Local ZKsync environment
```

This allows us to learn and test ZKsync development locally before deploying to a public ZKsync network.

---

## 7. Why Use `anvil-zksync` Instead of Docker?

Docker is a containerization platform. It is a way of packaging and running software; it is not itself a blockchain.

A ZKsync development environment can be run through Docker-based infrastructure, but the lesson introduced `anvil-zksync` as a more direct Foundry-oriented local development option.

The conceptual difference is:

```text
Docker-based approach
        ↓
Containerized ZKsync infrastructure
        ↓
Development
```

versus:

```text
anvil-zksync
        ↓
Local ZKsync development environment
        ↓
Development
```

Using `anvil-zksync` keeps the local workflow closer to the ordinary Foundry experience we already learned with `anvil`.

---

## 8. What Stays Familiar?

The important thing is that we are not learning an entirely unrelated development framework.

A lot of the workflow remains familiar:

| Normal Foundry | ZKsync Foundry |
|---|---|
| `forge build` | `forge build --zksync` |
| `anvil` | `anvil-zksync` |
| `cast` | ZKsync-compatible `cast` |
| RPC endpoint | ZKsync RPC endpoint |
| Deploy contract | Deploy contract |
| Interact with contract | Interact with contract |

The major change is the target environment and the tooling required to support it.

---

## Key Takeaways

1. ZKsync is the blockchain/L2 ecosystem; Foundry-ZKsync is the compatible development toolchain.
2. Foundry-ZKsync is based on/forked from Foundry rather than being an entirely unrelated framework.
3. `forge` is a command/tool within the Foundry toolchain.
4. A fork means developers take an existing project's source code and create another development line from it.
5. `forge build --zksync` builds the project for the ZKsync environment.
6. `anvil-zksync` provides a local ZKsync development environment.
7. The ZKsync tooling and the Solidity project live in separate directories.
8. Being inside the Solidity project when running the installer did not install the toolchain into that project.
9. Docker is a way of running software in containers; `anvil-zksync` is a Foundry-oriented local development tool.
10. Much of the Foundry workflow remains familiar; the target environment and ZKsync-specific tooling are what change.

---

## What This Lesson Added To My Mental Model

Before:

> "Foundry is the toolchain I use to build and deploy Solidity contracts."

After:

> "Foundry is a general development toolchain, and different blockchain environments can require specialized versions or extensions of that tooling. Foundry-ZKsync keeps the familiar Foundry workflow while adding support for developing against ZKsync."

The next important step is to actually build and deploy the Simple Storage contract using the ZKsync-specific toolchain so the differences become practical rather than purely theoretical.
