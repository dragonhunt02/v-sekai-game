FROM ubuntu:latest

ARG INPUT_GODOT_REV

# $HOME is overwritten by Github Action at runtime
ENV HOMEDIR '/root'

ENV BIN 'release/bin'
ENV BUILD_ARGS '--headless'
ENV BUILD_PLATFORMS 'Linux Web'
ENV GAME_REPO 'dragonhunt02/v-sekai-game'
ENV GODOT_REPO 'V-Sekai/world-godot'
ENV GODOT_ZIP 'v-sekai-world.zip'
ENV GODOT_EDITOR 'godot.linuxbsd.editor.double.x86_64'
ENV TEMPLATE_DIR "$HOMEDIR/export_templates"

WORKDIR $HOMEDIR

RUN apt-get update && apt-get upgrade -y \
  && apt-get install -y git curl jq unzip fontconfig file tree

RUN git clone "https://github.com/${GAME_REPO}.git" "./src"

RUN FILE_URL=$( \
        curl -sS -L \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com/repos/${GODOT_REPO}/releases" \
        | jq -r '.[0].assets.[] | select(.name == env.GODOT_ZIP).browser_download_url' \
    ) \
        && echo "Downloading ${FILE_URL}" \
        && curl -OL --url ${FILE_URL} \
        && echo "Downloaded ${GODOT_ZIP%.*} archive. Unzipping..." \
        && unzip ${GODOT_ZIP} && mv ${GODOT_ZIP%.*} ${HOMEDIR}/godot

RUN cp "./godot/${GODOT_EDITOR}" "./${GODOT_EDITOR}" \
        && chmod +x ${GODOT_EDITOR}

RUN mkdir -p ./src/${BIN} \
        && mkdir -p ${TEMPLATE_DIR} \
        && mv godot/* ${TEMPLATE_DIR}/ 

# Set export_templates parent folder in .cfg file
RUN sed -i -r "s|(^custom_template/[a-z]*=\")~|\1${HOMEDIR}|g" './src/export_presets.cfg'

# Import missing files
# RUN "./${GODOT_EDITOR}" --import --headless --build-solutions --path './src'

RUN cd ./src && echo -n $( git log --format="%(describe:tags,abbrev=0)-%h" -n 1 ) >version.txt \
    && if [ -n "${INPUT_GODOT_REV}" ]; then \
         echo -n "_editor-${INPUT_GODOT_REV}" >>version.txt; \
       fi

RUN GIT_REV=$(cat ./src/version.txt | tr -d '\n') \
       && for PLATFORM in ${BUILD_PLATFORMS}; do \
            echo "Building ${PLATFORM}..."; \
            # "./${GODOT_EDITOR}" ${BUILD_ARGS} --path './src' --export-release ${PLATFORM} ./${BIN}/v-sekai-game_${GIT_REV}_${PLATFORM} || true; \
          done

# Copy output to github
#RUN if [ -d "/github/workflows/" ]; then \
#        echo "Copying to Github output..."; \
#        cp ./src/$BIN/* /github/workflows/; \
#    else \
#        echo "Skipping Github output copy!"; \
#    fi

RUN echo "Test" > $HOMEDIR/src/$BIN/file_0.0.1_windows_le.test 
CMD ls . && echo "HOME\n" && ls $HOME && echo "WORKSPACE\n" && ls ${GITHUB_WORKSPACE} && echo "ROOT\n" && ls /root/ && \
        mkdir -p ${GITHUB_WORKSPACE}/releases && tree -a /root/src && \
        echo "Copying to Github output..." \
        && cp -v $HOMEDIR/src/$BIN/* ${GITHUB_WORKSPACE}/releases

#RUN ls -a ./src
RUN ls ./src/${BIN}
RUN file ./src/${BIN}/v-sekai*
