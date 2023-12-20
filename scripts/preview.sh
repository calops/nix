#! /bin/bash

file=$1

if [ -d $file ]; then
  eza --icons -lH --git
elif [ -f $file ]; then
  bat -n $file
fi
