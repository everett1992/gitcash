# Gitcash

This repo approximates a blockchain in git.
Hopefully it will help people who understand git understand blockchains.

## Dependencies

Probably bash, openssl, and [jq] but something else may have snuck in.

[jq]: https://stedolan.github.io/jq/

## commands

### `create-accounts`
This script creates key pairs which this demo uses to sign transactions.
Run this once before any other commands to setup the demos.

```
$ ./create-accounts
```

The script creates private keys in **./private-keys**.
You will need them later to create transactions.

#### Public private key cryptography

Public and private key are generated in pairs.
A private key is secret and should not be shared.

If a private key encrypts data the keys public twin can decrypt it.
And vice versa, when a public key encrypts data the private twin can decrypt it.

Data encrtpyed by a private key proves _the author, while data encrypted by a public key proves _the viewer_.
Specifically, it proves that the author or view controls the private key twin.

### `send`
This command creates new transactions.
The script adds the transaction to the pending transaction list.
The transaction will remain there until a miner validates it and includes it in a block.


```
$ ./send --from Alice --to Bob --key .private-keys/Alice.private.pem --amount 10
Signing transaction...
Verifying that private key matches form address...
Verified OK
Alice sent 10 coins to Bob (pending)
```

We will be mining our own blocks so we keep the pending transactions list locally.
In a real blockchain a sender will broadcast the transaction to the network.

A gitcash transaction sends an `amount` of coins `from` one address `to` another address.
A transaction includes the signature proving the author knew the private key of the `from` address.

```sh
sign private_key "${from} ${to} ${amount}"
```

Most blockchains implement transactions differently, and for good reasons.
_Once you publish a gitcoin transaction, anyone can duplicate it, charging you twice._
If `from`, `to`, and `amount` are the same an attacker can extract the signature from a previous transaction and reuse it.
Bitcoin is vulnerable to a similar replay attacks when it forks, tho there are mitigations.

### `balance`
This command lists balances in the ledger.

```
./balance Alice Bob
Account  Balance  Pending Balance
Alice:   100      90
Bob:     0        10
```

The **Balance** column shows the balance at the current block.
**Pending Balance** shows the balance if all pending transactions completed.

### `validate-pending-transactions`

This script executes transactions and updates the ledger.
Transactions are read from the pending transaction list and verified.
If they are valid they are removed from pending, added to the verified list, and changes are reflected in the ledger.
Otherwise they are added back to the pending list.

A valid transaction has a valid signature and does not overdraft the sender.

### `mine`

This script commits all verified transactions to a new block.
In Gitcash a block is a commit.

The ledger and verified transaction list are commited and a block is mined.
Gitcoin implements Proof of Work (tho it needn't).
The new commit is revised with a new message until the commit's hash starts with a number of zero's.

This is simialar to proof of work algorithms employed by production blockchains.


## Why prove work?

> TODO


