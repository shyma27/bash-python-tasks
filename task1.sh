#!/bin/bash

file="$1"
declare -A emails

while IFS= read -r line; do
    #extract full name, separate name and last name, capitalize first chars in each
    full_name=$(cut -f3 -d',' <<< $line)
    name=$(cut -f1 -d' ' <<< $full_name)
    last_name=$(cut -f2 -d' ' <<< $full_name)
    name_cap=$(echo "${name^}")
    last_name_cap=$(echo "${last_name^}")

    #write to output file
    id=$(cut -f1 -d',' <<< $line)
    location_id=$(cut -f2 -d',' <<< $line)
    
    email="${name:0:1}${last_name}@abc.com"
    email=${email,,}
    if [[ -v emails["$email"] ]]; then
        ((emails["$email"]++))
    else
        emails["$email"]=1
    fi
    
    department=$(cut -f6 -d',' <<< $line)

    #extract title whether there's "" or not
    if [[ "$line" == *\"* ]]; then
        title=$(cut -f2 -d'"' <<< "$line")
        title="\"$title\""
    else
        title=$(cut -f4 -d',' <<< "$line")
    fi

    echo "${id},${location_id},${name_cap} ${last_name_cap},${title},${email},${department}" >> "temp.csv"

done < <(sed '1d' $file)

#read temp.csv, check if email is in array, if yes - update, if no continue
echo "id,location_id,name,title,email,department" > accounts_new.csv
while IFS= read -r line; do
    full_name=$(cut -f3 -d',' <<< $line)
    name=$(cut -f1 -d' ' <<< $full_name)
    last_name=$(cut -f2 -d' ' <<< $full_name)
    location_id=$(cut -f2 -d',' <<< $line)
    if [[ "$line" == *\"* ]]; then
        email=$(cut -f3 -d'"' <<< "$line")
        email=${email:1:-1}
        if (( emails["$email"] > 1 )); then
            new_email="${name:0:1}${last_name}${location_id}@abc.com"
            new_email=${new_email,,}
            echo $line >> accounts_new.csv
            sed -i "s/$email/$new_email/" accounts_new.csv
            echo "change"
        else
            echo $line >> accounts_new.csv
            echo "no change"
        fi
    else
        email=$(cut -f5 -d',' <<< "$line")
        if (( emails["$email"] > 1 )); then
            new_email="${name:0:1}${last_name}${location_id}@abc.com"
            new_email=${new_email,,}
            echo $line >> accounts_new.csv
            sed -i "s/$email/$new_email/" accounts_new.csv
        else
            echo $line >> accounts_new.csv
        fi
    fi
done < "temp.csv"

rm temp.csv

echo "Done"