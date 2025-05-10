#!/usr/bin/env bash

# Check if hyprsunset is running using pidof
if pidof hyprsunset > /dev/null; then
    echo "☾"
else
    echo "☀︎"
fi
