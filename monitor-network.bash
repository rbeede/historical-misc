

if [ -z "$1" ]; then
	LOG_DIR=./monitor_data
else
	LOG_DIR="$1"
fi
LOG_DIR=$(readlink -f "$LOG_DIR")

echo Recording data to $LOG_DIR
echo To kill all processes run
echo "pkill -P $$; kill $$"
echo ""
echo "To summarize connection data:"
echo "ls nf_conntrack.* | xargs -n 1 grep -c udp"


mkdir --parents "$LOG_DIR"

cd "$LOG_DIR"

mkdir nf_conntrack.history.d/

date --utc > start_timestamp

PING_CMD="ping -4 -D -n -O -p ff"


$PING_CMD 8.8.8.8 &> ping_8.8.8.8.log &

DEFAULT_GATEWAY=$(ip -4 route show default | grep -Po '(?:[0-9]{1,3}\.){3}[0-9]{1,3}')

$PING_CMD $DEFAULT_GATEWAY &> ping_default_gateway_${DEFAULT_GATEWAY}.log &

while true; do
	date --utc >> resolve_ip_address.log
	curl --connect-timeout 3 --silent http://icanhazip.com &>> resolve_ip_address.log &
	pid1=$!

	date --utc >> nslookup_cloudflare-dns.log
	nslookup www.rodneybeede.com 1.1.1.1 &>> nslookup_cloudflare-dns.log &
	pid2=$!

	date --utc >> nslookup_local-dns.log
	nslookup www.rodneybeede.com $DEFAULT_GATEWAY &>> nslookup-local-dns.log &
	pid3=$!

	date --utc >> nslookup_google-dns.log
	nslookup www.rodneybeede.com 8.8.8.8 &>> nslookup_google-dns.log &
	pid4=$!

	ssh -o ConnectTimeout=1 root@$DEFAULT_GATEWAY 'cat /proc/net/nf_conntrack' > nf_conntrack.history.d/nf_conntrack.`date --utc --iso-8601=ns`

	find nf_conntrack.history.d/ -mtime +3 -exec rm {} \;

	sleep 1

	wait $pid1 $pid2 $pid3 $pid4
done
