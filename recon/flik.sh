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

echo "[+] Gathering full third-level domains with Sublist3r and Subfinder ..."
	for domain in $(cat $1/thirdlevel/third-level.txt); do python3.9 tools/Sublist3r/sublist3r.py -d $domain -o $1/thirdlevels/$domain.txt | sort -u >> $1/final.txt; done

echo "[+] Using aquatone for the subdomains"

cat $1/subdomains.txt | aquatone -out $1/aquatone/target --ports 
xlarge

#echo "[+] (In development) dirseach using seclist"

echo "[+] Scraping wayback data..."
	cat $1/alive.txt | tools/waybackurls/waybackurls | tee -a  $1/wayback/wayback_output1.txt
	sort -u $1/wayback/wayback_output1.txt >> $1/wayback/wayback_output.txt
	rm $1/wayback/wayback_output1.txt

echo "[+] Pulling and compiling all possible params found in wayback data..."
	cat $1/wayback/wayback_output.txt | grep '?*=' | cut -d '=' -f 1 | sort -u >> $1/wayback/params/wayback_params.txt
	for line in $(cat $1/wayback/params/wayback_params.txt);do echo $line'=';done

echo "[+] Pulling and compiling js/php/aspx/jsp/json files from wayback output..."
	for line in $(cat $1/wayback/wayback_output.txt);do
	    ext="${line##*.}"
	    if [[ "$ext" == "js" ]]; then
	        echo $line | sort -u | tee -a $1/wayback/extensions/js.txt
	    fi
	    if [[ "$ext" == "html" ]];then
	        echo $line | sort -u | tee -a $1/wayback/extensions/jsp.txt
	    fi
	    if [[ "$ext" == "json" ]];then
	        echo $line | sort -u | tee -a $1/wayback/extensions/json.txt
	    fi
	    if [[ "$ext" == "php" ]];then
	        echo $line | sort -u | tee -a $1/wayback/extensions/php.txt
	    fi
	    if [[ "$ext" == "aspx" ]];then
	        echo $line | sort -u | tee -a $1/wayback/extensions/aspx.txt
	    fi
	done

