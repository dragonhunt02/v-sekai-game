FROM ubuntu:latest

ARGS GITHUB_TOKEN

ENV BIN 'release/bin/'
ENV BUILD_ARGS '--headless'
ENV BUILD_PLATFORMS 'Linux,Linux1'
ENV GAME_REPO 'V-Sekai/v-sekai-game'
ENV GODOT_REPO 'V-Sekai/world-godot'
ENV GODOT_ZIP 'v-sekai-world.zip'
ENV GODOT_EDITOR 'godot.linuxbsd.editor.double.x86_64'

RUN git clone "https://github.com/${GODOT_REPO}.git"

RUN export FILE_URL=$( \
        curl -sS -L \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" \
        https://api.github.com/repos/${GODOT_REPO}/releases \
        | jq -r '.[0].assets.[] | select(.name == env.GODOT_ZIP).browser_download_url' \
    )

RUN echo Downloading "${FILE_URL}"　\
        && curl -OL --url ${FILE_URL} \
        && echo ${GODOT_ZIP%.*} \
        && unzip ${GODOT_ZIP} && mv ${GODOT_ZIP%.*} godot

RUN 
