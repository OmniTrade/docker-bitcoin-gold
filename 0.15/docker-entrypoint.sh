#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for bgoldd"

  set -- bgoldd "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "bgoldd" ]; then
  mkdir -p "$BITCOIN_GOLD_DATA"
  chmod 700 "$BITCOIN_GOLD_DATA"
  chown -R bitcoingold "$BITCOIN_GOLD_DATA"

	if [[ ! -s "$BITCOIN_GOLD_DATA/bgold.conf" ]]; then
		cat <<-EOF > "$BITCOIN_GOLD_DATA/bgold.conf"
		server=1
		printtoconsole=1
		rpcallowip=::/0
		rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
		rpcuser=${BITCOIN_RPC_USER:-bitcoingold}
		walletnotify=/usr/bin/rabbitmqadmin -H ${RABBITMQ_HOST:-localhost} -P 443 --ssl --vhost ${RABBITMQ_USER:-user} -u ${RABBITMQ_USER:-user} -p ${RABBITMQ_PASSWORD:-password} publish routing_key=minerx.deposit.coin payload='{"txid":"%s", "channel_key":"satoshi-gold"}' 
		EOF
		chown bitcoingold:bitcoingold "$BITCOIN_GOLD_DATA/bgold.conf"
	fi

  echo "$0: setting data directory to $BITCOIN_GOLD_DATA"

  set -- "$@" -datadir="$BITCOIN_GOLD_DATA"
fi

if [ "$1" = "bgoldd" ] || [ "$1" = "bgold-cli" ] || [ "$1" = "bitcoin-tx" ]; then
  echo
  exec gosu bitcoingold "$@"
fi

echo
exec "$@"
