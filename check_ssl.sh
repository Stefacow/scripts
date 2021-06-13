#!/bin/bash

day=86400 #seconds in day
exitresult=0

#try every link from the input file
while read link; do
        # now check if valid url
        regex='^[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]$'

        # check here if the fqdn is ok, based on regex from internet
        if [[ "$link" =~ $regex ]]; then
                # if ok, add https: and check if site exists
                if curl --insecure -I --output /dev/null --silent --head --fail "https://$link"; then                  
                        expr_date=$($openssl_timeout openssl s_client -servername $link -connect $link:443 </dev/null 2>/dev/null | \
                  openssl x509 -noout -dates 2>/dev/null | \
                  awk -F= '/^notAfter/ { print $2; exit }')

                        echo "$expr_date"
                        today=$(date +%s)
                        if ! [[ -z $expr_date ]]; then
                                expire=$(date +%s -d "$expr_date")
                                timeleft=`expr $expire - $today`

                                if [[ $today -ge $expire ]]; then
                                        echo -e "$link ---> link is expired!\n"
                                        exitcode=1
                                else
                                        days=$((timeleft / day))
                                        echo -e "$link ---> $days days left until certificate expires.\n"
                                fi
                        else
                                echo -e "$link has invalid date\n"
                                exitresult=-1
                        fi
                else
                        echo -e "https://$link does not exist\n"
                        exitresult=-1
                fi
        else
                echo -e "$link is not a valid FQDN\n"
                exitresult=-1
        fi
done < check_ssl.cfg
exit $exitresult
