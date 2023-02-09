#!/usr/bin/env bash

if [ ! -e "$1" ] 
then
	echo "[+] Creating folder $1"
	mkdir $1
else
	echo "File or Directory $1 exists."
	exit
fi

echo "[+] Gathering subdomains with amass"

amass enum -brute -o $1/subdomains.txt -d $1 -v

#echo "[+] Checking if subdomain is alive"

#cat subdomains.txt | httpx -o live-subdomains.txt

echo "[+] Using aquatone for the subdomains"

cat $1/subdomains.txt | aquatone -out $1/aquatone/target --ports 
xlarge

#echo "[+] (In development) dirseach using seclist"



