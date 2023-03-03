#!/bin/bash
if [ -z "$1" ]
then
echo " plz enter query"
exit
fi 
echo "starting uncover engine-----------------------------------------------------------------------------------------------"
uncover -q $1 -e shodan -o $1+ip.txt
censys search ' services.tls.certificates.leaf_data.subject_dn: $1' --index-type hosts | jq -c '.[] | {ip: .ip}'  >> ip.txt
sed -i 's/[^0-9,.]*//g' $1+2ip.txt
cat $1+2ip.txt | naabu >> $1+ip.txt
rm $1+2ip.txt
echo "all ip gathered-------------------------------------------------------------------------------------------------------"
echo "removing duplicate address--------------------------------------------------------------------------------------------"
cat $1+ip.txt | anew $1+ip.txt
echo "running nuclei--------------------------------------------------------------------------------------------------------"
cat $1+ip.txt | httpx  >> $1+iplive.txt
cat $1+iplive.txt | unfurl format %u%@%d% | nrich -
cat $1+iplive.txt | nuclei -silent -t $HOME/nuclei-templates/ -retries 2 -o $1+nuclei.txt
echo "start fuzzing----------------------------------------------------------------------------------------------------------"
for i in $(cat $1+iplive.txt); do DOMAIN=$(echo $i | unfurl format %s://%u%@%d%:%P); ffuf -u $i/FUZZ -w fuzz.txt ;done
rm $1+ip.txt
rm $1+ip.txt

