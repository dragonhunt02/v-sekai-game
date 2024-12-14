FROM debian:stable-slim

ARG INPUT_RELEASE_VERSION
ARG INPUT_API_KEY

ENV BUTLER_API_KEY INPUT_API_KEY

RUN apt-get update && apt-get install -y ca-certificates curl unzip

# Install Itch.io Butler
RUN curl -O -L https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default

RUN unzip butler.zip && chmod +x ./butler/butler && ./butler -V

RUN echo "Uploading ${ITCHIO_PATH} to ${ITCHIO_PROJECT}" \
    && /butler/butler push ${ITCHIO_PATH} ${ITCHIO_PROJECT}:${ITCHIO_CHANNEL} --userversion ${INPUT_RELEASE_VERSION}
