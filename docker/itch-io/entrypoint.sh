#!/bin/sh

echo "Github workspace ${GITHUB_WORKSPACE}"
pwd
tree -a -L 2 .

cd ${INPUT_FILEPATH}
for file in *; do \
   CHANNEL=$( echo "${file%.*}" | cut -d '_' -f3 | tr '[:upper:]' '[:lower:]'); \
   echo "channel ${CHANNEL}"; \
   echo "Uploading ${file} to ${INPUT_ITCHIO_PROJECT} for platform ${CHANNEL}..."; \
done
