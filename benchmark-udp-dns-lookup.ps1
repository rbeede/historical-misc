$nameresolvers = @(
	# CloudFlare
	"1.1.1.1",
	"1.0.0.3",
	"1.1.1.2",
	# Google
	"8.8.8.8",
	"8.8.4.4",
	# OpenDNS
	"208.67.222.222",
	"208.67.220.220",
	# AdGuard
	"94.140.14.14",
	"94.140.15.15",
	# CleanBrowsing
	"185.228.168.9",
	"185.228.169.9"	
)

while($true) {
	$RandomNumber = Get-Random
	
	foreach ($resolver in $nameresolvers) {
		nslookup ran$RandomNumber.localtest.me  $resolver
	}
	
	sleep 1
}
