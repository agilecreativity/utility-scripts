#!/bin/bash
current_version=`git branch | grep "*" | awk '{print$2}' | awk -F"-" '{print$4+1}' | bc`
echo $current_version
#DATE_TIME=`date +%Y_%m_%d_%H_%M_%S`
DATE_TIME=`date +%Y%m%d-%H%M%S`
#-- commit and increment the version, then checkout and work on
#   the new version
# TODO: may be don't commit if nothing changed, or if we have not added any files.
git commit -a -m poc-$DATE_TIME-$current_version
#-- then checkout and work on the new version immediately
git checkout -b wip-$DATE_TIME-$current_version
