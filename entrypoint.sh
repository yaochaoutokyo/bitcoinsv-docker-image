#!/bin/bash
set -e

if [[ "$1" == "bitcoin-cli" || "$1" == "bitcoin-tx" || "$1" == "bitcoind" || "$1" == "test_bitcoin" ]]; then
	mkdir -p "$BITCOIN_DATA"

	if [[ ! -s "$BITCOIN_DATA/bitcoin.conf" ]]; then
		cat <<-EOF > "$BITCOIN_DATA/bitcoin.conf"
		printtoconsole=1
		rpcallowip=::/0
		rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
		rpcuser=${BITCOIN_RPC_USER:-bitcoin}
		EOF
		chown bitcoin:bitcoin "$BITCOIN_DATA/bitcoin.conf"
	fi

	# ensure correct ownership and linking of data directory
	# we do not update group ownership here, in case users want to mount
	# a host directory and still retain access to it
	chown -R bitcoin "$BITCOIN_DATA"
	ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoin
	chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin
    
    # use exec to run command as PID 1, `docker stop` only send signal to PID 1 process, you need signal propagation to pass signal to child process 
    # refer to https://blog.csdn.net/boling_cavalry/article/details/93380447 , use gosu to run command with user bitcoin. (sudo will frok child process)
	exec gosu bitcoin "$@"
fi

# default command
exec "$@"