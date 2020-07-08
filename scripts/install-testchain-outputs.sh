#!/usr/bin/env bash
set -e

CWD=`dirname $0`
SOURCE=${1:-$CWD/../node_modules/@makerdao/testchain}
SCD_ADDRESSES=$SOURCE/out/addresses.json
MCD_ADDRESSES=$SOURCE/out/addresses-mcd.json

function jq_inplace {
  TMP=$(mktemp)
  jq "$1" > $TMP && mv $TMP "$2"
}

function set_address_and_abi {
  IFS=',' read NAME ABI <<< "${1}"
  ADDRESS=`jq ".$NAME" "$2"`
  cp $3/$ABI.abi $CONTRACTS/abis/$ABI.json
  
  if [[ $5 != null ]]
  then
    NAME=$NAME$5
  fi

  cat $4 | jq_inplace ".$NAME=$ADDRESS" $4
}

function add_prefix {
  for CONTRACT in "GEM" "GOV" "PIP" "PEP" "PIT" "ADM" "SIN" "SKR" "DAD" "MOM" "VOX" "TUB" "TAP" "TOP"
  do
    if [ `jq ".$CONTRACT" "$1"` != null ]
    then
      cat $1 | jq_inplace ".SAI_$CONTRACT = .$CONTRACT | del(.$CONTRACT)" $1
    fi
  done
}

DAI=$CWD/../packages/dai
MCD=$CWD/../packages/dai-plugin-mcd
SCD=$CWD/../packages/dai-plugin-scd
MIGRATIONS=$CWD/../packages/dai-plugin-migrations
GOVERNANCE=$CWD/../packages/dai-plugin-governance

. $MCD/scripts/install-testchain-outputs.sh
. $SCD/scripts/install-testchain-outputs.sh
. $DAI/scripts/install-testchain-outputs.sh
. $MIGRATIONS/scripts/install-testchain-outputs.sh
. $GOVERNANCE/scripts/install-testchain-outputs.sh

yarn build