#!/bin/bash
# Simple script that will perform git init on current directory,
# and create simple brance with the 'wip-YYYY-MM-DD-hh-mm-ss-number' format.
git init .
git add .
git commit -a -m "Initial import"
#DATE_TIME=`date +%Y_%m_%d_%H_%M_%S`
DATE_TIME=`date +%Y%m%d-%H%M%S`
git checkout -b wip-$DATE_TIME-1
