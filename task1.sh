#!/bin/bash

file="$1"
output="./accounts_new.csv"
echo "id,location_id,name,title,email,department" > $output

while IFS= read -r line; do
    #extract full name, separate name and last name, capitalize first chars in each
    full_name=$(cut -f3 -d',' <<< $line)
    name=$(cut -f1 -d ' ' <<< $full_name)
    last_name=$(cut -f2 -d ' ' <<< $full_name)
    name_cap=$(echo "${name^}")
    last_name_cap=$(echo "${last_name^}")

    #write to output file
    id=$(cut -f1 -d',' <<< $line)
    location_id=$(cut -f2 -d',' <<< $line)
    email=$(cut -f5 -d',' <<< $line | echo ${name:0:1}${last_name}@abc.com)
    department=$(cut -f6 -d',' <<< $line)

    #extract title whether there's "" or not
    if [[ "$line" == *\"* ]]; then
        title=$(awk -F'"' '{print $2}' <<< "$line")
        title="\"$title\""
    else
        title=$(cut -f4 -d',' <<< "$line")
    fi

    echo "${id},${location_id},${name_cap} ${last_name_cap},${title},${email,,},${department}" >> $output
    

done < <(sed '1d' $file)

# awk -F',' 'BEGIN {OFS=","} 
# NR==FNR {count[$5]++; next} 
# count[$5] > 1 {sub(/@/, $2 "@", $5)} 
# {print}' $output $output > temp.csv && mv temp.csv accounts_new.csv

awk 'BEGIN {
    FPAT = "([^,]+)|(\"[^\"]+\")";
    OFS = ",";
}
NR==FNR {
    count[$5]++; 
    next
}
count[$5] > 1 {
    sub(/@/, $2 "@", $5)
}
{ print }' "$output" "$output" > temp.csv && mv temp.csv "$output"