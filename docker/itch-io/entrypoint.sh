#!/bin/sh

echo "Github workspace ${GITHUB_WORKSPACE}"
pwd
tree -a -L 2 .

cd ${INPUT_FILEPATH}
for file in *; do \
   export CHANNEL=$( grep -E -io "windows|linux|mac|android" ); \
   echo "channel ${CHANNEL}";
   echo $( grep -E -io "windows|linux|mac|android" );
   echo "Uploading ${file} to ${INPUT_ITCHIO_PROJECT} for platform ${CHANNEL}..."; \
done
