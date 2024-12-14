#!/bin/sh

echo "Workspace release folder: ${GITHUB_WORKSPACE}/${INPUT_FILEPATH}"

cd ${INPUT_FILEPATH}
for file in *; do
   CHANNEL=$( echo "${file}" | cut -d '_' -f3 | cut -d '.' -f1 | tr '[:upper:]' '[:lower:]');
   echo "Uploading ${file} to ${INPUT_ITCHIO_PROJECT} for platform ${CHANNEL}...";
done
