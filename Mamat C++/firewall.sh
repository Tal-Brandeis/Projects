#!/bin/bash
rules=$(cat < $@)
packets_in=$(cat)
while read line; do 
	curr_rule=$(echo "$line"| sed '/^$/d' | sed 's/#.*//')
	num=$(echo "$curr_rule" | wc -w)
	if [[ "$num" -gt 0 ]]; then
		#c for col
		c1=$(echo "$line" | awk -F "," '{print $1}')
		c2=$(echo "$line" | awk -F "," '{print $2}')
		c3=$(echo "$line" | awk -F "," '{print $3}')
		c4=$(echo "$line" | awk -F "," '{print $4}' | sed 's/#.*//')

		tmp1=$(echo "$packets_in" | ./firewall.exe $c1 | ./firewall.exe $c2)
		tmp2=$(echo "$tmp1" | ./firewall.exe $c3 | ./firewall.exe $c4)
		
		res_out+=$(echo "$tmp2" | sed 's/ //g')
		res_out+=$'\n'
			
	fi

done < $1
a=$(echo "$res_out" | sed '/^$/d'| sort)
echo "$a"