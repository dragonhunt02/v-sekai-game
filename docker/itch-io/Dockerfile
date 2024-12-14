FROM debian:stable-slim

ARG INPUT_RELEASE_VERSION
ARG INPUT_API_KEY
ARG INPUT_ITCHIO_PROJECT

ENV BUTLER_API_KEY INPUT_API_KEY
ENV FILES_PATH /github/workflows
ENV HOME /root

RUN apt-get update && apt-get install -y ca-certificates curl unzip

WORKDIR $HOME

# Install Itch.io Butler
RUN curl -L -o butler.zip https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default

RUN mkdir butler && unzip -d butler/ butler.zip && chmod +x ./butler/butler && ./butler -V

RUN ls -a ./butler && ls -a ${FILES_PATH}

RUN cd ${FILES_PATH} && for file in *; do \
      CHANNEL=$( grep -E -io "windows|linux|mac|android" ); \
      echo "Uploading ${file} to ${ITCHIO_PROJECT} for platform ${CHANNEL}..."; \
      done

      # ./butler/butler push ${file} ${INPUT_ITCHIO_PROJECT}:${CHANNEL} --userversion ${INPUT_RELEASE_VERSION}; \
