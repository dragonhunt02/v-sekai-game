FROM ubuntu:latest

ARG GITHUB_TOKEN

ENV HOME '/root/'
ENV BIN 'release/bin/'
ENV BUILD_ARGS '--headless'
ENV BUILD_PLATFORMS 'Linux,Linux1'
ENV GAME_REPO 'V-Sekai/v-sekai-game'
ENV GODOT_REPO 'V-Sekai/world-godot'
ENV GODOT_ZIP 'v-sekai-world.zip'
ENV GODOT_EDITOR 'godot.linuxbsd.editor.double.x86_64'
ENV TEMPLATE_DIR "$HOME/.local/share/godot/export_templates"

WORKDIR $HOME

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
        && unzip ${GODOT_ZIP} && mv ${GODOT_ZIP%.*} ${HOME}/godot

RUN mv "./godot/${GODOT_EDITOR}" "./${GODOT_EDITOR}" \
        && chmod +x ${GODOT_EDITOR}

RUN export GODOT_VERSION=$( ./${GODOT_EDITOR} --version | sed 's/\.[^.]*$//' ) \
        mkdir -p ${TEMPLATE_DIR} \
        echo ${GODOT_VERSION} > "${TEMPLATE_DIR}/version.txt"

RUN mv godot/* ${TEMPLATE_DIR}/ \
        && sed -i -r "s|(^custom_template/[a-z]*=\")~|\1${HOME}|g" './src/export_presets.cfg' \
        && mkdir -p ${BIN}

RUN tree -a . && tree -a -L 2 ${TEMPLATE_DIR}


