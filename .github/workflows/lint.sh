#!/bin/bash
set -e
#ls -a -R .
EXCLUDE="
addons/vrm
"

EXCLUDE_DIRS=''

# Separate by newline
OLD=$IFS
IFS='
'
for DIR in $EXCLUDE; do
    EXCLUDE_DIRS="$EXCLUDE_DIRS--exclude-dir=$DIR "
done
IFS=$OLD
EXCLUDE_DIRS=$( echo $EXCLUDE_DIRS | tr -d "\n" )
echo "$EXCLUDE_DIRS"

EXCLUDE_DIRS=addons/vrm

echo "Linter: Start custom linter...";
match_error=false;

# Decision https://github.com/V-Sekai/v-sekai-game/issues/474#issuecomment-2603661420
# Forbid assert()
matches=$( grep -rn --include='*.gd' --exclude-dir="addons/vrm" -e 'assert(' . || true )
if [ -n "$matches" ]; then
    echo 'Linter: "assert()" usage is forbidden (assert checks are skipped in release versions causing potential undefined behaviour)';
    echo 'Linter: use constructs like "if not ...: push_error(...); return" instead';
    echo "$matches";
    match_error=true;
fi

# Decision https://github.com/V-Sekai/v-sekai-game/issues/475#issue-2802564439
# Forbid printerr()
matches=$( grep -rn --include='*.gd' $EXCLUDE_DIRS -e 'printerr(' . || true )
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
