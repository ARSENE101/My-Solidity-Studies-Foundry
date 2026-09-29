# Wallet Security and Keystores

This milestone documents my first Foundry workflow for deploying with an encrypted wallet keystore instead of passing a private key directly to Forge.

The goal was to understand how Foundry/Cast can keep the private key encrypted at rest while still allowing Forge to sign deployment transactions.

## What I had before

Earlier in this project, I used a `.env` file containing a private key for local Anvil deployment.

That worked, but the private key was still stored as plaintext.

For this milestone, I wanted to change that habit and learn to work with an encrypted keystore instead.

## 1. Import the wallet into Cast

I used:

```bash
cast wallet import default-key --interactive
```

Cast prompted me for:

```text
Enter private key:
Enter password:
```

I entered the private key once and created a password for the keystore.

Cast then reported:

```text
`default-key` keystore was saved successfully.
Address: 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
```

The important result was that the private key was no longer something I needed to pass directly to Forge for deployment. Cast stored it as an encrypted keystore under the name `default-key`.

The address shown by Cast is the public address derived from the private key. It is safe to use as the transaction sender.

## 2. Deploy using the encrypted account

I then used Forge with the imported account:

```bash
forge script script/DeploySimpleStorage.s.sol     --rpc-url port     --broadcast     --account default-key     --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
```

The first two attempts failed because Anvil was not running:

```text
Error: failed to retrieve chain ID from fork endpoint

Context:
- MPP HTTP request to http://127.0.0.1:8545/ failed:
  ... Connection refused ...
```

After Anvil was running again, the same deployment command succeeded.

Forge detected:

```text
Chain 31337
```

and asked:

```text
Enter keystore password:
```

I entered the password created when importing `default-key`.

The deployment completed successfully:

```text
ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
```

The deployed contract was:

```text
SimpleStorage
Contract Address: 0x5FbDB2315678afecb367f032d93F642f64180aa3
```

The transaction hash was:

```text
0x27503ea4671459bb1c9b57e0ebd9a55fd25599b544794e026ed462f14c42ba60
```

The deployment was made against my local Anvil network (chain ID `31337`).

## 3. What the Forge flags mean

### `--account default-key`

Tells Forge which encrypted Cast keystore account to use for signing.

The private key itself is not written into the command.

### `--sender 0xf39...`

Specifies the address that Forge should use as the transaction sender.

This is the public address associated with `default-key`.

### `--broadcast`

Tells Forge to actually send the transaction to the configured RPC endpoint instead of only simulating the script.

### `--rpc-url port`

Uses the `port` RPC alias configured in `foundry.toml`:

```toml
[rpc_endpoints]
port = "${RPC_URL}"
```

For this project, the RPC URL points to the local Anvil node.

## 4. Interactive password vs password file

The interactive workflow asks for the keystore password:

```text
Enter keystore password:
```

Patrick also introduced a faster workflow using Forge's `--password-file` option.

The idea is to place the keystore password in a local file such as:

```text
.password
```

and then pass:

```bash
--password-file .password
```

For example:

```bash
forge script script/DeploySimpleStorage.s.sol     --rpc-url port     --broadcast     --account default-key     --sender 0xf39Fd6e51aad88f6f4ce6aB8827279cffFb92266     --password-file .password
```

I have **not** treated the `.password` workflow as completed in this milestone. It was introduced as the next convenience step after the encrypted-keystore workflow.

If a password file is used, it must never be committed to GitHub.

## 5. Why this is different from storing the private key in `.env`

The earlier approach was conceptually:

```text
Plaintext private key
        ↓
.env
        ↓
Forge
        ↓
sign transaction
```

The encrypted-keystore approach is:

```text
Private key
     ↓
Cast wallet import
     ↓
Encrypted keystore
     ↓
default-key
     ↓
password
     ↓
Forge
     ↓
sign transaction
```

The important security improvement is that the private key is stored encrypted rather than as plaintext in the project environment.

The password unlocks the encrypted keystore locally. It is not sent to the blockchain.

## 6. What I learned

This milestone taught me:

- A private key and wallet address are different things.
- The private key is the secret; the address is public.
- Cast can store a private key in an encrypted keystore.
- `default-key` is the name I gave that stored account.
- Forge can sign transactions using the encrypted account through `--account`.
- `--sender` identifies the public address associated with the account.
- `--broadcast` changes a script from simulation to an actual transaction.
- The keystore is persistent on the machine, unlike the normal temporary Anvil chain state.
- A keystore password is different from the private key.
- A password file is a convenience mechanism, not a replacement for encryption.
- Secrets such as private keys and password files should not be committed to GitHub.

## Milestone result

I successfully moved from passing a plaintext private key to Forge toward using an encrypted Cast keystore for deployment.

The deployment of `SimpleStorage` was successfully completed on my local Anvil network using:

```bash
--account default-key
```

and:

```bash
--sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
```

This is my first documented step toward making secure key handling part of my normal Foundry workflow.
