#!/bin/sh
montage $(find ./chips -type f | sort -n) -geometry 16x16 chipset.png
