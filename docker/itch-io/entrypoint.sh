#!/bin/sh

echo "Github workspace ${GITHUB_WORKSPACE}"
pwd
tree -a -L 2 .

cd ${INPUT_FILEPATH}
for file in *; do \
   CHANNEL=$( cut -d '_' -f3 | tr '[:upper:]' '[:lower:]'); \
   echo "channel ${CHANNEL}";
   echo $( sed -r 's/.*(windows|linux|mac|android).*/\1/' );
   echo "Uploading ${file} to ${INPUT_ITCHIO_PROJECT} for platform ${CHANNEL}..."; \
done
