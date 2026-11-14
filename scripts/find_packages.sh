#!/bin/bash

ASTLINUX_FOLDER=astlinux-338e17c4efd61b63fbecb66d3132a32e68440d83

process_file() {
while IFS= read -r line; do
    # Process each line here
    echo "Processing: $line"
    grep -rl "$line" $ASTLINUX_FOLDER | grep "\.in$\|\.ext$"
done < <(cat $1)
}

cat $ASTLINUX_FOLDER/x86_64-configs/astlinux-ast18se.config \
    $ASTLINUX_FOLDER/x86_64-configs/astlinux-ast20.config \
    $ASTLINUX_FOLDER/x86_64-configs/initrd.config \
    $ASTLINUX_FOLDER/runnix.config \
    $ASTLINUX_FOLDER/runnix-iso.config | grep "^BR2_PACKAGE_" | grep "=y" | sed -e 's@=y@@g' | sort -u \
    > /tmp/temp.config
process_file /tmp/temp.config
