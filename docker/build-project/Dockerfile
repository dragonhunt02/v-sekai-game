FROM ubuntu:latest

ARG INPUT_NIGHTLY

# $HOME is overwritten by Github Action at runtime
ENV HOMEDIR '/root'
#Linux Windows Mac Web Linux_arm64'
ENV BIN 'release/bin'
ENV BUILD_ARGS '--headless'
ENV BUILD_PLATFORMS 'QuestAndroid'
ENV GAME_REPO 'dragonhunt02/v-sekai-game'
ENV GODOT_REPO 'V-Sekai/world-godot'
ENV GODOT_ZIP 'v-sekai-godot-linuxbsd.zip'
ENV GODOT_TPZ 'v-sekai-godot-templates.zip'
ENV GODOT_EDITOR 'godot.linuxbsd.editor.double.x86_64'
ENV TEMPLATE_DIR "$HOMEDIR/.local/share/godot/export_templates/4.4.dev"
ENV ANDROID_SDK_ROOT "$HOMEDIR/android_sdk"
ENV ANDROID_HOME "$HOMEDIR/android_sdk"

WORKDIR $HOMEDIR

# Using process substitution feature (not POSIX)
SHELL [ "/bin/bash", "-c" ]

RUN apt-get update && apt-get upgrade -y \
  && apt-get install -y git curl jq zip unzip fontconfig openjdk-17-jdk file tree

RUN git clone "https://github.com/${GAME_REPO}.git" "./src"

RUN TPZ_URLS=$( \
        curl -sS -L \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com/repos/${GODOT_REPO}/releases" \
        | jq -r '.[0].assets.[] | select(.name | startswith(env.GODOT_TPZ)).browser_download_url | @sh' | tr -d "\'" \
    ) \
        && echo "${TPZ_URLS}" | while read -r URL; do \
            echo "Downloading ${URL}"; \
            curl -OL --url "${URL}" \
            && echo "Downloaded ${URL} archive."; \
        done && echo "Unzipping..." \
            && cat ${GODOT_TPZ}.* > "${GODOT_TPZ%.*}-merge.zip" && rm ${GODOT_TPZ}.* \
            && unzip "${GODOT_TPZ%.*}-merge.zip" && rm "${GODOT_TPZ%.*}-merge.zip" \
            && mv ${GODOT_TPZ%.*}/${GODOT_TPZ%.*}.tpz templates.zip && rmdir ${GODOT_TPZ%.*} \
            && unzip templates.zip && rm templates.zip
            
RUN tree

# Get latest Godot editor metadata
RUN curl -sS \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${GODOT_REPO}/releases" \
    | jq -r '.[0]' > godot_editor_json.txt

# Get editor commit SHA
RUN GODOT_TAG=$( cat 'godot_editor_json.txt' | jq -r '.tag_name') \
    && read obj_type obj_sha < <( echo $( \
        curl -sS \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com/repos/${GODOT_REPO}/git/ref/tags/${GODOT_TAG}" \
        | jq -r '.object.type, .object.sha' ) ) \
    && if [ $obj_type == "commit" ]; then \
           GODOT_SHA=${obj_sha}; \
       else \
           GODOT_SHA=$( curl -sS \
           -H "Accept: application/vnd.github+json" \
           "https://api.github.com/repos/${GODOT_REPO}/git/tags/${obj_sha}" \
           | jq '.object.sha' ); \
       fi \
    && echo "Godot Editor SHA: ${GODOT_SHA}" \
    && echo "${GODOT_SHA}" > godot_editor_sha.txt

# Get editor
RUN FILE_URL=$( \
        cat 'godot_editor_json.txt' \
        | jq -r '.assets.[] | select(.name == env.GODOT_ZIP).browser_download_url' \
    ) \
        && echo "Downloading ${FILE_URL}" \
        && curl -OL --url ${FILE_URL} \
        && echo "Downloaded ${GODOT_ZIP%.*} archive. Unzipping..." \
        && unzip ${GODOT_ZIP} && mv ${GODOT_ZIP%.*} ${HOMEDIR}/godot

RUN tree ${HOMEDIR}

RUN cp "./godot/${GODOT_EDITOR}" "./${GODOT_EDITOR}" \
        && chmod +x ${GODOT_EDITOR}

RUN mkdir -p ./src/${BIN} \
        && mkdir -p ${TEMPLATE_DIR} \
        && mv -v templates/* ${TEMPLATE_DIR}/

# Set export_templates parent folder in .cfg file and copy editor settings
RUN sed -i -r "s|(^custom_template/[a-z]*=\")~|\1${HOMEDIR}|g" './src/export_presets.cfg' \
    && mkdir -p ${HOMEDIR}/.config/godot/ \
    && cp -v ./src/editor_settings-4.tres ${HOMEDIR}/.config/godot/editor_settings-4.tres


RUN curl -sS -OL 'https://dl.google.com/android/repository/platform-tools-latest-linux.zip'
#RUN mkdir temp && unzip platform-tools-latest-linux.zip -d temp && tree && exit 1

# Setup Android
RUN curl -sS -OL 'https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip' \
    && unzip commandlinetools-linux-11076708_latest.zip \
    && mkdir -p ${ANDROID_SDK_ROOT} \
    && yes | ./cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses \
    && yes | ./cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "ndk;23.2.8568313" 'cmdline-tools;latest' 'build-tools;34.0.0' 'platforms;android-34' 'cmake;3.22.1' \
    && unzip platform-tools-latest-linux.zip -d ${ANDROID_SDK_ROOT} \
    && sed -i -r "s|(^export/android/android_sdk_path = \")~|\1${HOMEDIR}|g" './src/editor_settings-4.tres' \
    && mkdir -p ./src/android/plugins ./src/android/build \
    && touch ./src/android/build/.gdignore \
    && echo 4.4.dev >> ./src/android/.build_version \
    && unzip ${TEMPLATE_DIR}/android_source.zip -d ./src/android/build

RUN echo $( cat './src/editor_settings-4.tres' ) && tree .
RUN exit 1

# Import missing files
RUN "./${GODOT_EDITOR}" --import --headless --build-solutions --path './src'

RUN cd ./src && echo -n $( git log --format="%(describe:tags,abbrev=0)" -n 1 | cut -d '-' -f1 ) >version.txt \
    && if [ "${INPUT_NIGHTLY}" == 'true' ]; then \
         echo -n "-$( git rev-parse --short HEAD )" >>version.txt; \
         GODOT_SHA=$( cat ${HOMEDIR}/'godot_editor_sha.txt' ); \
         echo -n "_editor-${GODOT_SHA:0:7}" >>version.txt; \
       fi

RUN cat ./src/version.txt 

RUN GIT_REV=$(cat ./src/version.txt | tr -d '\n') \
       && for PLATFORM in ${BUILD_PLATFORMS}; do \
            echo "Building ${PLATFORM}..."; \
            BUILD_DIR="./${BIN}"; EXT=''; \
            if [ "${PLATFORM}" == 'Windows' ]; then \
                EXT='.exe'; \
            elif [ "${PLATFORM}" == 'Android' ]; then \
                EXT='.apk'; \
            elif [ "${PLATFORM}" == 'Mac' ]; then \
                EXT='.zip'; \
            elif [ "${PLATFORM}" == 'Web' ]; then \
                BUILD_DIR="${BUILD_DIR}/v-sekai-game_${GIT_REV}_${PLATFORM}"; \
                mkdir -p "./src/${BUILD_DIR}"; \
            fi; \
            "./${GODOT_EDITOR}" ${BUILD_ARGS} --path './src' --export-release ${PLATFORM} ${BUILD_DIR}/v-sekai-game_${GIT_REV}_${PLATFORM}${EXT} || true; \
            if [ "${PLATFORM}" == 'Web' ]; then \
                zip -r "./src/${BIN}/v-sekai-game_${GIT_REV}_${PLATFORM}.zip" ./src/${BUILD_DIR}; \
                rm -r ./src/${BUILD_DIR}; \
            fi; \
          done

# Copy output to github
#RUN if [ -d "/github/workflows/" ]; then \
#        echo "Copying to Github output..."; \
#        cp ./src/$BIN/* /github/workflows/; \
#    else \
#        echo "Skipping Github output copy!"; \
#    fi

RUN echo "Test" > $HOMEDIR/src/$BIN/file_0.0.1_windows_le.test 
#CMD ls . && echo "HOME\n" && ls $HOME && echo "WORKSPACE\n" && ls ${GITHUB_WORKSPACE} && echo "ROOT\n" && ls /root/ && \
CMD mkdir -p ${GITHUB_WORKSPACE}/releases && tree -a /root/src && \
        echo "Copying to Github output..." \
        && cp -v $HOMEDIR/src/$BIN/* ${GITHUB_WORKSPACE}/releases \
        && echo "INPUT_NIGHTLY: $INPUT_NIGHTLY"

#RUN ls -a ./src
RUN ls ./src/${BIN}
RUN file ./src/${BIN}/v-sekai*
