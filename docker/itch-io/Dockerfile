FROM debian:stable-slim
#FROM ubuntu:latest

ARG INPUT_RELEASE_VERSION
ARG INPUT_API_KEY
ARG INPUT_ITCHIO_PROJECT
ARG INPUT_FILEPATH

ENV BUTLER_API_KEY INPUT_API_KEY
ENV FILES_PATH /github/workspace
#ENV HOME /root

RUN apt-get update && apt-get install -y ca-certificates curl unzip tree

RUN echo "\n\n" && pwd && tree -a -L 2 .

# WORKDIR $HOME

# Install Itch.io Butler
RUN curl -L -o butler.zip https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default

RUN mkdir butler && unzip -d butler/ butler.zip \
      && chmod +x ./butler/butler && ./butler/butler -V

RUN echo ${GITHUB_WORKSPACE} && ls -a /
RUN ls -a . && ls -a ./butler # && ls -a ${INPUT_FILEPATH}

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN ls -a . && echo "path $PATH" 
#&& ls -a $PATH

CMD ["/bin/sh", "/usr/bin/entrypoint.sh"]

      # ./butler/butler push ${file} ${INPUT_ITCHIO_PROJECT}:${CHANNEL} --userversion ${INPUT_RELEASE_VERSION}; \
