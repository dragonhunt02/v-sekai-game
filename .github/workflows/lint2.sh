#!/bin/bash
set -e

EXCLUDE="
./addons/vrm/.*
"

export DIR_PATHS2=()
# Separate by newline
OLD=$IFS
IFS='
'
set -f
for PATTERN in $EXCLUDE; do
    PATTERNS+=("-not -regex \"$PATTERN\"")
done
set +f

IFS=$OLD

echo "Linter: Start custom linter...";
match_error=false;

# Decision https://github.com/V-Sekai/v-sekai-game/issues/474#issuecomment-2603661420
# Forbid assert()
matches=$( bash -c "find . -type f -name '*.gd' ${PATTERNS[@]} -exec echo {} \;" )
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
