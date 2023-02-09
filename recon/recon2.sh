#!/bin/bash

#subjack='~/go/bin/subjack'

if [ ! -d "$1" ]; then
	mkdir $1
fi
if [ ! -d "$1/third-level" ]; then
	mkdir "$1/thirdlevel"
fi
if [ ! -d "$1/potential_takeovers" ];then
    mkdir $1/potential_takeovers
fi
if [ ! -d "$1/wayback" ];then
    mkdir $1/wayback
fi
if [ ! -d "$1/wayback/params" ];then
    mkdir $1/wayback/params
fi
if [ ! -d "$1/wayback/extensions" ];then
    mkdir $1/wayback/extensions
fi

echo "[+] Gathering subdomains with Sublist3r, Subfinder"

#sublister
python3.9 tools/Sublist3r/sublist3r.py -d $1 -o $1/final.txt

#subfinder
subfinder -d $1 -o $1/final.txt

echo $1 >> $1/final.txt

echo "[+] Compiling the file"

cat $1/final.txt | grep -po "(\w+\.\w+\.\w+)$" | sort -u >> $1/thirdlevel/third-level.txt

echo "[+] Gathering full third-level domains with Sublist3r and Subfinder ..."
	for domain in $(cat $1/thirdlevel/third-level.txt); do python3.9 tools/Sublist3r/sublist3r.py -d $domain -o $1/thirdlevels/$domain.txt | sort -u >> $1/final.txt; done

echo "[+] Is it alive ?"
	cat $1/final.txt | sort -u | ./tools/httprobe/httprobe -c 80 --prefer-https | sort -u >> $1/alive.txt

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
