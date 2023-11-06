#!/bin/bash

bot_token="$1"
inputFile="$2"

regex_channel_ID="(?<=/attachments/)\d+"
regex_cdn_url='https:\/\/cdn\.discordapp\.com[^"]+'
regex_cdn_no_params='https:\/\/cdn\.discordapp\.com\/attachments\/\d+\/\d+\/[^?]+'
regex_ex_value="(?<=\?ex=)[^&]+"

function main () {
    inputFileContent=$(cat "$inputFile")
    
    # find link with oldest expire timestamp
    findOldestURL "$inputFileContent"

    current_timestamp=$(date +%s)

    if [ "$oldestTimestamp" -lt "$current_timestamp" ]; then
        updateURL
        main
    fi

    timeDifference=$(($oldestTimestamp - $current_timestamp))

    if [ "$timeDifference" -le "500" ]; then
        sleep $timeDifference
        sleep 10
        updateURL "overwrite"
        main
    fi

    if [ "$timeDifference" -gt "500" ]; then
        targetTimestamp=$(($oldestTimestamp - 120))
        cron_date=$(date -d "@$targetTimestamp" "+%M %H %d %m")
    fi
}

function getMessages () {
    messagesJson=$(mktemp)
    curl -H "Authorization: Bot $bot_token" https://discord.com/api/v9/channels/$1/messages?limit=100 > "$messagesJson"
    messagesJsonContent=$(cat "$messagesJson")
}

function findOldestURL () {
    #clear decimal value buffer
    decimal_values=()

    # Get CDN URLs
    URLs=($(echo "$1" | grep -o -P "$regex_cdn_url"))

    # extract expiry value from input
    URL_ex_values=($(echo "$1" | grep -o -P "$regex_ex_value"))

    #convert hex expiry values to decimal
    for ex_value in "${URL_ex_values[@]}"; do
      decimal_value=$(printf "%d" "0x$ex_value")
      decimal_values+=("$decimal_value")
    done

    #sort decimal values
    sorted_values=($(for val in "${decimal_values[@]}"; do echo "$val"; done | sort -n))

    #convert decimal value to hex
    target_ex_value=$(printf "%X" "${sorted_values[0]}")

    #find target url
    for URL in "${URLs[@]}"; do
      if [[ "${URL,,}" == *"?ex=${target_ex_value,,}"* ]]; then
        target_url="$URL"
        break
      fi
    done

    #function output
    oldest_url=$target_url
    oldestTimestamp=${sorted_values[0]}
}

function updateURL () {
    # clean inputLink (grep regex_cdn_no_params)
    clean_input_URL=($(echo "$oldest_url" | grep -o -P "$regex_cdn_no_params"))
    
    old_channel_ID=$channel_ID

    # get channel id
    channel_ID=($(echo "$oldest_url" | grep -o -P "$regex_channel_ID"))

    if [[ "$channel_ID" != "$old_channel_ID" ]]; then
        # get messagesJson
        sleep 5
        getMessages "$channel_ID"
    fi

    if [[ "$1" == "overwrite" ]]; then
        getMessages "$channel_ID"
    fi

    # create messagesURL array
    messagesURLs=($(echo "$messagesJsonContent" | grep -o -P "$regex_cdn_url"))

    # clear found state
    found=false

    # find corresponding messageLink in array by comparing with substring match
    for messagesURL in "${messagesURLs[@]}"; do
        if [[ "${messagesURL,,}" == *"${clean_input_URL,,}"* ]]; then
            new_url="$messagesURL"
            found=true
            # sed replace full inputLink with full messageLink
            sed -i "s|$(echo "$oldest_url" | sed 's/[\&/]/\\&/g')|$(echo "$new_url" | sed 's/[\&/]/\\&/g')|g" "$inputFile"
            break
        fi
    done

    if [ "$found" = false ]; then
        echo
        echo "FATAL: Condition not met in the loop. No link found?"
        echo Input URL: $clean_input_URL
        echo
        exit 404
    fi
}

main
echo "$cron_date *"
