#!/bin/bash

# get, add, drain
pool=$1
cmd=$2
arg=$3 # optional - cmd arg


pool_port=0 # port of load balancer pool

server_port=0
server_id="" # Nginx server id in the pool; ex: id=0
first_server_port=0 # first port in the pool
next_port=0

# error codes
# ERR_POOL_EMPTY=10
ERR_UNKNOWN_CMD=11
ERR_UNKNOWN_POOL=11
ERR_NO_NEXT_PORT=12 # cannot determine next avail port

function  get_server_info() {
        pool_servers=`$GET_CMD`
        server_port=`echo $pool_servers | egrep -o '127.0.0.1:[0-9]+' | head -1 | cut -d: -f2`
        if [[ $server_port -eq 0 ]]; then
                # empty pool
                server_id="NA"
                server_port=0
                return
                # exit $ERR_POOL_EMPTY
        fi
        server_id=`echo $pool_servers | egrep -o 'id=[0-9]+' | head -1`
}

# gets the next avail port; gives up after 10 attempts
function get_next_port(){

  if [[ $server_port -eq 0 ]]; then
    next_port=$first_server_port
    return
  fi

	cnt=1
	while [[ $cnt -le 10 ]];
	do
		next_port=$((server_port+cnt))
		nc -w 1 localhost $next_port
		if [[ $? ]]; then
			return
		fi
		cnt=$((cnt+1))
	done

	exit $ERR_NO_NEXT_PORT
}

function add_new_server() {
    local next_server_port=$1
    # curl http://127.0.0.1:8000/upstream_conf?add=\&upstream=goservers\&server=127.0.0.1:10000\&slow_start=30s
    ret=`${ADD_CMD}:${next_server_port}&slow_start=30s`
    server_id=`echo $ret | egrep -o 'id=[0-9]+' | head -1`
    # server 127.0.0.1:10000; # id=8

}

function drain_server() {
    local drain_server_id=$1
    # curl http://127.0.0.1:8000/upstream_conf?add=\&upstream=goservers\&id=0\&drain=1
    ret=`${DRAIN_CMD}\&${drain_server_id}\&drain=1`
    server_id=$drain_server_id
}

function remove_server() {
    local rm_server_id=$1
    # curl http://127.0.0.1:8000/upstream_conf?remove=\&upstream=goservers\&id=5
    ret=`${REMOVE_CMD}\&${rm_server_id}`
    server_id=$rm_server_id
}

case $pool in
	goservers)
		pool_port=8000
    first_server_port=10000
		;;
  luaservers)
  	pool_port=8001
    first_server_port=11000
  	;;
  pyservers)
		pool_port=8002
    first_server_port=12000
		;;
	*)
		echo "Unknown upstream pool"
		exit $ERR_UNKNOWN_POOL
esac

CURL_CMD="curl -s --max-time 2"
POOL_REQ="$CURL_CMD http://127.0.0.1:${pool_port}/upstream_conf"
GET_CMD="${POOL_REQ}?upstream=$pool"
ADD_CMD="${POOL_REQ}?add=&upstream=$pool&server=127.0.0.1"
DRAIN_CMD="${POOL_REQ}?add=\&upstream=$pool"
REMOVE_CMD="${POOL_REQ}?remove=\&upstream=$pool"


case $cmd in
	get)
		get_server_info
    get_next_port
		echo "$server_id $server_port $next_port"
		;;

	add)
		add_new_server $arg
		echo $server_id
		;;

	drain)
    drain_server $arg
    echo $server_id
		;;

  remove)
    remove_server $arg
    echo $server_id
    ;;
	*)
		exit $ERR_UNKNOWN_CMD
esac
