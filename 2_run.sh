#!/bin/bash

ip="192.168.1.101,192.168.2.101,192.168.3.101"
mongo_host="127.0.0.1:27017"
mongo_user="root"
mongo_pass="mongo_pw_1337"
auth_db="admin"

# Unarchiving the domains-master.zip
if [ -f "./domains-master.zip" ]; then
	unzip domains-master.zip && \
	rm -rf domains-master.zip
else
	echo "domains-master.zip does not exists"
	exit 1
fi

# Unpacking hosts
cd domains-master && \
sed -i '/^test_lfs$/d' unpack.sh && \
sed -i '/^lfs_pull$/d' unpack.sh && \
bash unpack.sh && \
cd ..

# Creating a single hosts.txt with all the hotsnames
cat domains-master/data/*/*.txt > hosts.txt && \
rm -rf domains-master


# Compiling Go Utilities
if go --version; then
	cd go_utilities/selgen && go build && cd ../.. && \
	cd go_utilities/tldgen && go build && cd ../.. && \
	cd go_utilities/dmarcgen && go build && cd ../.. 
else
	echo "Go is not installed"
	exit 1
fi

# Generating list of root domains
go_utilities/tldgen/tldgen hosts.txt && \
rm -rf hosts.txt && \
# Generaing list of selectors
go_utilities/selgen/selgen domains.txt && \
# Generating list of hosts for DMARC
go_utilities/dmarcgen/dmarcgen domains.txt

# ZDNS Scan
ulimit -n 360000 
zdns --local-addr $ip --input-file=domains.txt SPF --name-servers=8.8.8.8,8.8.4.4 --threads 2500 --output-file spf_raw.json 
zdns --local-addr $ip --input-file=dmarc.txt DMARC --name-servers=8.8.8.8,8.8.4.4  --threads 2500 --output-file dmarc_raw.json 
zdns --local-addr $ip --input-file=selectors.txt TXT --name-servers=8.8.8.8,8.8.4.4  --threads 2500 --output-file dkim_raw.json
zdns --local-addr $ip --input-file=domains.txt MX --name-servers=8.8.8.8,8.8.4.4  --threads 2500 --output-file mx_raw.json
zdns --local-addr $ip --input-file=domains.txt NS --name-servers=8.8.8.8,8.8.4.4  --threads 2500 --output-file ns_raw.json

# Convert Raw results to Processed JSON files
cat spf_raw.json | jq -c '{domain: .name, spf: .data.spf}' > spf.json && rm -rf spf_raw.json
cat dmarc_raw.json | jq -c '{domain: .name, dmarc: .data.dmarc}' > dmarc.json && rm -rf dmarc_raw.json
cat dkim_raw.json | grep -i "v=DKIM" | jq -c '{host: .name, dkim: .data.answers[].answer}' | jq -c 'select(.dkim|contains("v="))' | grep -P '^((?!v\=\").)*$' | jq  -c '{domain: (.host | split("_domainkey.")[-1:]) | join(""), host: .host, dkim: .dkim}' > dkim.json && rm -rf dkim_raw.json
cat mx_raw.json | grep 'type":"MX' | jq -c '{domain: .name, mx: .data.answers[].answer}' > mx.json && rm -rf mx_raw.json
cat ns_raw.json | grep 'type":"NS' | jq -c '{domain: .name, ns: .data.answers[].answer}' > ns.json && rm -rf ns_raw.json

# Import the results to a mongodb instance
mongoimport -h $mongo_host -d data -c spf -u $mongo_user -p $mongo_pass --authenticationDatabase $auth_db --file spf.json
mongoimport -h $mongo_host -d data -c dmarc -u $mongo_user -p $mongo_pass --authenticationDatabase $auth_db --file dmarc.json
mongoimport -h $mongo_host -d data -c dkim -u $mongo_user -p $mongo_pass --authenticationDatabase $auth_db --file dkim.json
mongoimport -h $mongo_host -d data -c mx -u $mongo_user -p $mongo_pass --authenticationDatabase $auth_db --file mx.json
mongoimport -h $mongo_host -d data -c ns -u $mongo_user -p $mongo_pass --authenticationDatabase $auth_db --file ns.json

