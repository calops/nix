#! /usr/bin/env bash

file=$1

if [ -d $file ]; then
	eza --color=always --icons -lH --git $file
elif [ -f $file ]; then
	bat -n $file
fi
