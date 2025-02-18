#!/bin/bash
set -e

#ls -a -R .
#./addons/vrm/*
EXCLUDE="
./addons/vrm/.*
"

DIR_PATHS=''
# Separate by newline
OLD=$IFS
IFS='
'
set -f
for DIR in $EXCLUDE; do
    DIR_PATHS="$DIR_PATHS -regex \'$DIR\' "
done
set +f

IFS=$OLD
DIR_PATHS=$( echo $DIR_PATHS | tr -d "\n" )
echo "$DIR_PATHS"
#echo 'find . -type f -name "*.gd" '"${DIR_PATHS}"' -exec grep -nH "assert(" {} \;'
echo "find . -type f -D -name '*.gd' ${DIR_PATHS} -exec echo {} \;"
EXCLUDE_DIRS="addons/vrm"
#-not -path "./addons/vrm/*"
echo "Linter: Start custom linter...";
#set -o noglob # Disable glob for parameter expansion

match_error=false;

# Decision https://github.com/V-Sekai/v-sekai-game/issues/474#issuecomment-2603661420
# Forbid assert()
matches=$( find . -type f -name "*.gd" ${DIR_PATHS} -printf "%h\n" ) #-exec echo {} \; )
#matches=$( find . -type d ${DIR_PATHS} -exec grep -nH --include="*.gd" 'assert(' {}/* \; )
#matches=$( find . -type f -name "*.gd" ${DIR_PATHS} -exec grep -nH 'assert(' {} \; )


#$( grep -rn --include='*.gd' --exclude-dir="./addons/vrm/" -e 'assert(' . || true )
if [ -n "$matches" ]; then
    echo 'Linter: "assert()" usage is forbidden (assert checks are skipped in release versions causing potential undefined behaviour)';
    echo 'Linter: use constructs like "if not ...: push_error(...); return" instead';
    echo "$matches";
    match_error=true;
fi

# Decision https://github.com/V-Sekai/v-sekai-game/issues/475#issue-2802564439
# Forbid printerr()
matches=$( find . -type f -name "*.gd" $DIR_PATHS -exec grep -nH 'printerr(' {} \; )
if [ -n "$matches" ]; then
    echo 'Linter: "printerr()" usage is forbidden (error output won'\''t be shown in Godot Debug panel)';
    echo 'Linter: use "push_error()" instead';
    echo "$matches";
    match_error=true;
fi

if [ "$match_error" == 'true' ]; then
    echo 'Linter: Solve errors and run again';
    exit 1;
else
    echo "Linter: All checks passed!"
fi
