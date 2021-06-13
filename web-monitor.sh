#!/bin/bash
#Monitors web server via curl and reports if web server is down.
#add "> /dev/null" after line 12 if want to suppress when webserver is up.

while read link; do

regex='^[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]$'

if [[ "$link" =~ $regex ]]; then
        if curl -s --head "https://$link" | grep "HTTP/2 200" > /dev/null
                then
                        echo "The web server on "https://$link" is up."
                else
                        echo "The web server on "https://$link" is down!"
        fi
fi
done < check_ssl.cfg                    
