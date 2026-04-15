#!/bin/bash

cat output.txt | awk -F'  ' '
/ok|not ok/ {
    status = ($1 == "ok") ? "true" : "false"
    split($3, duration, " ")
    count = length(duration)
    sub(/, [^,]*$/, "|&", $3)
    split($3, name, "|")
    print "{\"name\": \"" name[1] "\", \"status\": " status ", \"duration\": \"" duration[count] "\"}"
}' | jq -s '{
    testName: "Asserts Samples",
    tests: .,
    summary: (
        (map(select(.status == true)) | length) as $s |
        (map(select(.status == false)) | length) as $f |
        ($s + $f) as $total |
        {
            success: $s,
            failed: $f,
            rating: (if $total > 0 then (($s / $total * 10000 | round) / 100) else 0 end),
            duration: (map(.duration | rtrimstr("ms") | tonumber) | add | tostring + "ms")
        }
    )
}'