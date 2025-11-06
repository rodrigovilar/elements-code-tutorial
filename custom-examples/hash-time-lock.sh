#!/bin/bash
set -euo pipefail

pause() { read -p "Press Enter to continue..." ; echo ; echo ; }

# Note: this assumes that you have a local program called elements-cli
# that can be run with no arguments and that talks to a local elementsd
# synchronized to Liquid testnet.  That might not be true for everyone's
# setup, in which case you have to change the references to elements-cli
# here to whatever command line has this effect for you.
# We do need some elements-cli and elementsd because we actively
# use them during the demo!
#
# Sempre use o comando docker compose diretamente para garantir portabilidade
ELEMENTS_CLI="docker compose exec -T elementsd1 elements-cli"

PROGRAM_SOURCE="$HOME/tiago/SimplicityHL/examples/htlc.simf"
WITNESS_FILE="$HOME/tiago/SimplicityHL/examples/htlc.complete.wit"
# This is an unspendable public key address.
# It is semi-hardcoded in some Simplicity tools. You can change it in order
# to make existing contract source code have a different address on the
# blockchain (I think) but you must use a NUMS method to make sure that
# the key is unspendable. If someone else offers you a contract, you must
# make sure that the internal key used for that instance of the contract
# is an unspendable value (if it is changed from this default). Otherwise
# the contract creator may be able to unilaterally steal value from
# the contract.
INTERNAL_KEY="50929b74c1a04954b78b4b6035e97a5e078a5a0f28ec96d547bfee9ace803ac0"
TMPDIR=$(mktemp -d)

PRIVKEY_1="0000000000000000000000000000000000000000000000000000000000000001"

# Hardcoded address of the Liquid testnet for returning tLBTC
# (so that they aren't wasted!)
# We could also send these to our own wallet, but here we are choosing
# to send them back.
# todo: atualizar para o endereço do cliente
FAUCET_ADDRESS=tlq1qq2g07nju42l0nlx0erqa3wsel2l8prnq96rlnhml262mcj7pe8w6ndvvyg237japt83z24m8gu4v3yfhaqvrqxydadc9scsmw
FAUCET_ADDRESS=$($ELEMENTS_CLI validateaddress "$FAUCET_ADDRESS" | jq -r .unconfidential)

for variable in PROGRAM_SOURCE WITNESS_FILE INTERNAL_KEY PRIVKEY_1 FAUCET_ADDRESS
do
    echo -n "$variable = "
    eval echo \$$variable
done

pause

# Compile p2ms.simf (pay to multisig) program
echo simc $PROGRAM_SOURCE
simc $PROGRAM_SOURCE

pause

# Extract the compiled program from the output of that command
COMPILED_PROGRAM=$(simc "$PROGRAM_SOURCE" | tail -1)

echo hal-simplicity simplicity info $COMPILED_PROGRAM
hal-simplicity simplicity info $COMPILED_PROGRAM | jq
BYTECODE=$(hal-simplicity simplicity info "$COMPILED_PROGRAM" | jq -r .commit_decode)
CMR=$(hal-simplicity simplicity info "$COMPILED_PROGRAM" | jq -r .cmr)
CONTRACT_ADDRESS=$(hal-simplicity simplicity info "$COMPILED_PROGRAM" | jq -r .liquid_testnet_address_unconf)
echo

for variable in CMR CONTRACT_ADDRESS
do
    echo -n "$variable = "
    eval echo \$$variable
done

pause

# Here we use a curl command to contact the Liquid Testnet faucet to
# ask it to fund our contract
echo Running curl to connect to Liquid Testnet faucet...
FAUCET_TRANSACTION=$(bash ~/faucet.sh "$CONTRACT_ADDRESS" | bash ~/extract-transaction.sh)

echo "FAUCET_TRANSACTION = $FAUCET_TRANSACTION"


# aqui termina a parte de criacao do contrato e funding

pause

# Ask elements-cli to create a minimal PSET which asks to spend the
# value that the faucet sent our contract, by sending it back to
# FAUCET_ADDRESS (the address the contract is asked to send this value
# to) -- less a fee
echo $ELEMENTS_CLI createpsbt "[ { \"txid\": \"$FAUCET_TRANSACTION\", \"vout\": 0 } ]" "[ { \"$FAUCET_ADDRESS\": 0.00099900 }, { \"fee\": 0.00000100 } ]"
PSET=$($ELEMENTS_CLI createpsbt "[ { \"txid\": \"$FAUCET_TRANSACTION\", \"vout\": 0 } ]" "[ { \"$FAUCET_ADDRESS\": 0.00099900 }, { \"fee\": 0.00000100 } ]")

echo "Minimal PSET is $PSET"

pause

# Now we will attach a lot of stuff to this PSET.

# First, we want to know more details related to the incoming transaction
# that funded the contract and that we are now attempting to spend.
#
# Although we may have to wait until we know about the faucet transaction
# locally (instead of getting the details from the API).
echo "Looping until our local elementsd has our faucet transaction."

sleep 5
while ! $ELEMENTS_CLI gettxout $FAUCET_TRANSACTION 0 | grep . > /dev/null
do
    sleep 5
done

pause

echo $ELEMENTS_CLI gettxout $FAUCET_TRANSACTION 0
$ELEMENTS_CLI gettxout $FAUCET_TRANSACTION 0 | tee "$TMPDIR/faucet-tx-data.json" | jq

HEX=$(jq -r .scriptPubKey.hex < "$TMPDIR/faucet-tx-data.json")
ASSET=$(jq -r .asset < "$TMPDIR/faucet-tx-data.json")
VALUE=$(jq -r .value < "$TMPDIR/faucet-tx-data.json")

echo Extracted hex:asset:value parameters $HEX:$ASSET:$VALUE

pause

echo hal-simplicity simplicity pset update-input "$PSET" 0 -i "$HEX:$ASSET:$VALUE" -c "$CMR" -p "$INTERNAL_KEY"
hal-simplicity simplicity pset update-input "$PSET" 0 -i "$HEX:$ASSET:$VALUE" -c "$CMR" -p "$INTERNAL_KEY" | tee "$TMPDIR/updated.json" | jq

PSET=$(jq -r .pset < "$TMPDIR/updated.json")

pause

# Now we have to generate the sighash and then, for this case, make
# signatures on it corresponding to the signatures of 2 out of 3 authorized
# keys.

# Signature 1
echo hal-simplicity simplicity sighash "$PSET" 0 "$CMR" -x "$PRIVKEY_1"
hal-simplicity simplicity sighash "$PSET" 0 "$CMR" -x "$PRIVKEY_1" | jq
SIGNATURE_1=$(hal-simplicity simplicity sighash "$PSET" 0 "$CMR" -x "$PRIVKEY_1" | jq -r .signature)
echo "Signature 1 is $SIGNATURE_1 (different from JSON due to signing nonce)"

pause

# Put the signatures into the appropriate place in the .wit file
# (these substitutions are extremely hard-coded for this specific
# .wit file)
echo "Copying signatures into copy of witness file $WITNESS_FILE..."
cp $WITNESS_FILE "$TMPDIR/witness.wit"
sed -i '' "s/, 0x[^)]*)/, 0x$SIGNATURE_1)/" "$TMPDIR/witness.wit"

echo "Recompiling Simplicity program with attached populated witness file..."
echo simc $PROGRAM_SOURCE "$TMPDIR/witness.wit"
simc $PROGRAM_SOURCE "$TMPDIR/witness.wit" | tee "$TMPDIR/compiled-with-witness"

PROGRAM=$(sed '1d;3,$d' "$TMPDIR/compiled-with-witness")
WITNESS=$(sed '1,3d;5,$d' "$TMPDIR/compiled-with-witness")

pause

echo hal-simplicity simplicity pset finalize "$PSET" 0 "$PROGRAM" "$WITNESS"
hal-simplicity simplicity pset finalize "$PSET" 0 "$PROGRAM" "$WITNESS" | jq
PSET=$(hal-simplicity simplicity pset finalize "$PSET" 0 "$PROGRAM" "$WITNESS" | jq -r .pset)

pause

echo $ELEMENTS_CLI finalizepsbt "$PSET"
$ELEMENTS_CLI finalizepsbt "$PSET" | jq
RAW_TX=$($ELEMENTS_CLI finalizepsbt "$PSET" | jq -r .hex)

pause

# My copy of elementsd is too old for some reason to do the normal
# TXID=$($ELEMENTS_CLI sendrawtransaction "$RAW_TX")
# so I will submit this via the web API instead:
echo Submitting raw transaction via Liquid Testnet web API...
echo -n "Resulting transaction ID is "
TXID=$(curl -s -X POST "https://blockstream.info/liquidtestnet/api/tx" -d "$RAW_TX")
echo $TXID
echo "View online at https://blockstream.info/liquidtestnet/tx/$TXID?expand"

echo