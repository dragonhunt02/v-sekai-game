# Itch.io publish release - Docker image
## Run from Docker
```
docker compose up
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
