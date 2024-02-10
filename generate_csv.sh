#!/bin/bash

# CSV file path
output_csv="output.csv"

# Ensure the CSV file is empty before we start
> "$output_csv"

# Loop over the values 1-10
for i in {1..10}; do
    # Compose the RainLang string with the current binding
    rainlang_string=$(rain dotrain compose --input test.rain -e main -b bind=$i)

    # Evaluate the RainLang string and append the output to the CSV file
    ./target/release/rain_i9r_cli eval --fork-url https://rpc.ankr.com/polygon_mumbai --fork-block-number 45658085 --deployer 0x0754030e91F316B2d0b992fe7867291E18200A77 --source-index 0 --rainlang-string "$rainlang_string" >> "$output_csv"
done

echo "CSV generation complete. Output stored in $output_csv"
cat "$output_csv"
