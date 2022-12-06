#!/bin/bash

array=()
readarray -t array < $1

for line in "${array[@]}"; do 
    echo $line
done
