#!/bin/bash

file="$1"
# output="temp.csv"
# final_output="accounts_new.csv"
#echo "id,location_id,name,title,email,department" > "accounts_new.csv"

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
        title=$(cut -f2 -d'"' <<< "$line")
        title="\"$title\""
    else
        title=$(cut -f4 -d',' <<< "$line")
    fi

    echo "${id},${location_id},${name_cap} ${last_name_cap},${title},${email,,},${department}" >> "temp.csv"
    

done < <(sed '1d' $file)

# awk -F',' 'BEGIN {OFS=","} 
# NR==FNR {count[$5]++; next} 
# count[$5] > 1 {sub(/@/, $2 "@", $5)} 
# {print}' $output $output > temp.csv && mv temp.csv accounts_new.csv

awk 'BEGIN {
    FPAT = "([^,]+)|(\"[^\"]+\")";
    OFS = ",";
    print "id,location_id,name,title,email,department"
}
NR==FNR {
    count[$5]++; 
    next
}
{
# 1. Update the email if it is a duplicate
if (count[$5] > 1) {
    sub(/@/, $2 "@", $5)
}

# 2. Check if the line already ends with a comma. 
# If not, add one.
if ($0 !~ /,$/) {
    print $0 ","
} else {
    print $0
}
}' "temp.csv" "temp.csv" > "accounts_new.csv"
rm temp.csv