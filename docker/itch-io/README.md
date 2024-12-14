# Itch.io Publish Release - Docker image
## Run from Docker
```
docker run --rm --name itch-publish --workdir /github/workspace \
-e "INPUT_API_KEY" -e "INPUT_FILEPATH" -e "INPUT_ITCHIO_PROJECT" \
-e "INPUT_RELEASE_VERSION" -e "HOME" \
-v "/home/user/v-sekai-release":"/github/workspace" \
 itchio:latest
```

## Run as Github Action
```
job-name:
    runs-on: ubuntu-latest
    needs: 
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      ...

      - name: Docker Itch.io Publish
        uses: ./docker/itch-io
        with:
          api_key: ${{ secrets.ITCH_IO_API_KEY }}
          filepath: ${{ github.workspace }}/files_folder
          itchio_project: project_name
          release_version: 0.0.1
```
