#!/bin/bash

ANALYZER_DIR=analyzers

check_file() {
    local source="$1"
    for analyzer in $( find $ANALYZER_DIR -type f )
    do
        if [ ! -x $analyzer ]; then
            echo "Analyzer is not executable file: $analyzer"
            continue
        fi
        RESULT=$($analyzer $source)
        echo "Analyzer [$analyzer] result: $RESULT"
    done
}

main() {
    for iteration in $(seq 10); do
        local C_SOURCE=$(mktemp)
        csmith > $C_SOURCE
        check_file $C_SOURCE
    done
}

main
