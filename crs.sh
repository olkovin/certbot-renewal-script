#!/bin/bash

# Load configuration variables
source "$(dirname "$0")/config_crs.conf"
domains_file="$(dirname "$0")/config_crs_domains_list.conf"

# Initialize variables
action_taken=false
active_certs=$(certbot certificates | awk '!/Private Key Path|Certificate Path|Serial Number|Key Type/' | grep -v "Saving debug log" | grep -v "Found the following")
certbot_args="--dns-route53 --non-interactive --agree-tos --email $email --server https://acme-v02.api.letsencrypt.org/directory -v"
new_line="%0a"
check_mark="%E2%9C%85"
cross_mark="%E2%9D%8C"
warning_sign="%E2%9A%A0%EF%B8%8F"
list_sign="%F0%9F%97%BA"
new_sign="%F0%9F%86%95"
message=""

# Loop through each domain in the domains file
while read -r domain; do
    # Check if the certificate exists for the domain
    if certbot certificates | grep -q "$domain"; then
        echo "Certificate for $domain already exists."
        # Get expiration date of certificate
        expiration_date=$(openssl x509 -enddate -noout -in "/etc/letsencrypt/live/$domain/cert.pem" | sed 's/notAfter=//')
        expiration_epoch=$(date -d "$expiration_date" +"%s")
        current_epoch=$(date +%s)
        time_until_expiry=$(( $expiration_epoch - $current_epoch ))
        # Renew the certificate if it will expire within 30 days
        if [ $time_until_expiry -lt 2592000 ]; then
            echo "Certificate for $domain is due for renewal. Attempting renewal..."
            # Renew the certificate
            certbot renew -d $domain $certbot_args
            # Check if renewal was successful
            if [ $? -eq 0 ]; then
                echo "Renewal for $domain was successful!"
                action_taken=true
                message+="$check_mark Renewed certificate for $domain.$new_line"
            else
                echo "Renewal for $domain failed."
                message+="$cross_mark Failed to renew certificate for $domain.$new_line$warning_sign Please check the log file for details.$new_line$new_line"
            fi
        else
            echo "Certificate for $domain is not yet due for renewal."
            message+="$list_sign $domain is not yet due for renewal.$new_line"
        fi
    else
        echo "Creating certificate for $domain..."
        # Create the certificate
        certbot certonly -d $domain $certbot_args
        # Check if creation was successful
        if [ $? -eq 0 ]; then
            echo "Certificate creation for $domain was successful!"
            action_taken=true
            message+="$new_sign Created certificate for $domain.$new_line"
        else
            echo "Certificate creation for $domain failed."
            message+="$cross_mark Failed to create certificate for $domain.$new_line$warning_sign Please check the log file for details.$new_line$new_line"
        fi
    fi
done < "$domains_file"


# Send message to Telegram with results
if [ "$action_taken" = true ]; then
    active_certs=$(certbot certificates | awk '!/Private Key Path|Certificate Path|Serial Number|Key Type/' | grep -v "Saving debug log" | grep -v "Found the following")
    message="* Certificate creation/renewal complete. * $new_line Here is the results:$new_line$new_line$message $new_line$new_line $list_sign List of active certificates:$active_certs"
else
    message="$check_mark * No certs need to be created/renewed. * $new_line No actions were performed. $new_line$new_line$list_sign Here is the list of active certificates:$active_certs"
fi

curl -s -X POST "https://api.telegram.org/bot$telegram_bot_token/sendMessage" -d "chat_id=$telegram_chat_id" -d "text=$message"
