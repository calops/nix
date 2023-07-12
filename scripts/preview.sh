#! /bin/bash

file=$1

if [ -d $file ]
then
    exa --icons -lH --git
elif [ -f $file ]
then
    bat -n $file
fi
