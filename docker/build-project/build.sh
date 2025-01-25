set -e

cd $HOMEDIR

git clone "https://github.com/${GAME_REPO}.git" "./src"

if [ "${INPUT_NIGHTLY}" == 'true' ]; then
    GIT_REV=$(cat ./src/version-nightly.txt | tr -d '\n');
else
    GIT_REV=$(cat ./src/version.txt | tr -d '\n');
fi

# Import
"./${GODOT_EDITOR}" --editor --headless --quit --path './src'

for PLATFORM in ${BUILD_PLATFORMS}; do \
    echo "Building ${PLATFORM}..."; \
    BUILD_DIR="./${BIN}"; EXT=''; \
    if [ "${PLATFORM}" == 'Windows' ]; then \
        EXT='.exe'; \
    elif [ "${PLATFORM}" == 'QuestAndroid' ]; then \
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


echo "Test" > $HOMEDIR/src/$BIN/file_0.0.1_windows_le.test 
#ls . && echo "HOME\n" && ls $HOME && echo "WORKSPACE\n" && ls ${GITHUB_WORKSPACE} && echo "ROOT\n" && ls /root/ && \
mkdir -p ${GITHUB_WORKSPACE}/releases && tree -a /root/src && \
    echo "Copying to Github output..." \
    && cp -v $HOMEDIR/src/$BIN/* ${GITHUB_WORKSPACE}/releases \
    && echo "INPUT_NIGHTLY: $INPUT_NIGHTLY"
#RUN ls -a ./src
ls ./src/${BIN}
file ./src/${BIN}/v-sekai*
