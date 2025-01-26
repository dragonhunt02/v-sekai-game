set -e

cd $HOMEDIR

git clone "https://github.com/${GAME_REPO}.git" "./src1"

mv ./src1/* ./src

convert -density 1200 -resize 432x432 './src/vsk_default/icon/v_sekai_logo_bg.svg' './src/vsk_default/icon/adaptive_background_432x432.png'
ls -a './src/vsk_default/icon/'


# Set export_templates parent folder in .cfg file and copy editor settings
sed -i -r "s|(^[a-z]*/[a-z]*=\")~|\1${HOMEDIR}|g" './src/export_presets.cfg' \
    && mkdir -p ${HOMEDIR}/.config/godot/ \
    && sed -i -r "s|(^export/android/android_sdk_path = \")~|\1${HOMEDIR}|g" './src/editor_settings-4.tres' \
    && sed -i -r "s|(^export/android/debug_keystore = \")~|\1${HOMEDIR}|g" './src/editor_settings-4.tres' \
    && cp -v ./src/editor_settings-4.tres ${HOMEDIR}/.config/godot/editor_settings-4.4.tres


cd ./src && echo -n $( git log --format="%(describe:tags,abbrev=0)" -n 1 | cut -d '-' -f1 ) >version.txt \
    && cp version.txt version-nightly.txt \
    && echo -n "-$( git rev-parse --short HEAD )" >>version-nightly.txt \
    && GODOT_SHA=$( cat ${HOMEDIR}/'godot_editor_sha.txt' ) \
    && echo -n "_editor-${GODOT_SHA:0:7}" >>version-nightly.txt \
    && cd ..
    
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
