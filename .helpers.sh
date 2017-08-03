# shared bash scripts.

readonly root="${BASH_SOURCE%/*}"

# Path to public keys for all accounts.
readonly public_keys="${root}/.keys"

# list of pending transactions
readonly pending="${root}/.pending"

# database of current balances
readonly ledger="${root}/ledger"

# list of transactions verified in this block.
readonly verified="${root}/verified"

# Path to private keys. A blockchain would not normally know the private keys
# for any accounts.
readonly _private_keys="${root}/.private-keys"

# Get the private key for an account.
# 1: the address of an account known to the block chain (Alice, Bob, ...)
public() {
  local address="${1:-}"
  local path="${public_keys}/$address.public.pem"

  if [ ! -s "$path" ]; then
    return 1
  fi

  echo "$path"
}

assert_public() {
  if ! public $2 > /dev/null; then
    echo "$1 '$2' did not match any known public keys" >&2
    exit 1
  fi
}


assert_private() {
  if [ -z "$2" ] || [ ! -s "$2" ]; then
    echo "$1 - did not find private key at path '$2'" >&2
    exit 1
  fi
}

assert_int() {
  local re='^[0-9]+$'
  if [[ -z "$2" || ! $2 =~ $re ]]; then
    echo "$1 '$2' must be a positive integer" >&2
    exit 1
  fi
}


# Create a signature of the transaction with a private key.
sign() {
  local key=$1
  local transaction=$2

  # XXX xxd is used to avoid some shell escaping problems. I couldn't get
  # openssl's -hex argument to create a valid signature and I didn't want to
  # write to disk.
  openssl dgst -sha256 -sign "$key" -out - <(echo -n "$transaction") \
    | xxd -p
}

# verify that a transaction matches it's signature and that he from matches
# the public/private key pair used to sign the transaction.
verify() {
  local from=$1
  local signature=$2
  local transaction=$3
  openssl dgst -sha256 \
    -verify $(public "$from") \
    -signature <(echo -n "$signature" | xxd -p -r) \
    <(echo -n "$transaction")
}
