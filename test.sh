#!/bin/bash

TIME="10"

DEF_PARAMs="-t $TIME"

DIR=$(pwd)

red='\e[0;31m'
o='\e[0;33m'
color='\e[0;32m'
NC='\e[0m' # No Color

PARSE_PATH="$DIR/parse_data/"

LIST="LIST.txt"
PATHs="PATHs.txt"

read -a FILES <<< $(cat $PARSE_PATH$PATHs)

test_analyzer()
{
	local index=0
	local PARAMS="$@"

	for file in "${FILES[@]}"
	do

		RESULT=$(./main.sh $PARAMS -f "$file" | grep -uoE "\[$ANALYZER\] result: .*")

		#echo $RESULT 

		if [[ ! "$RESULT" =~ "[$ANALYZER] result:" ]]; then
			echo -e "${red}NO RESULT${NC}"
		elif [[ "${CONTROL[$index]}" == "" ]]; then
			echo -e "${red}ERROR${NC}"
		elif [[ $RESULT =~ "${CONTROL[$index]}" ]]; then
			echo -e "$index.	${CONTROL[$index]}	${color}OK${NC}"
		elif [[ $RESULT =~ "TIMEOUT" ]]; then
			echo -e "$index.	${CONTROL[$index]}	${o}TIMEOUT${NC}"
		else
			echo -e "$index.	${CONTROL[$index]}	${red}WRONG${NC}		$RESULT "
		fi

		index=$((index+1))

	done
}

test()
{
	echo "______________|["$ANALYZER"]|_________________"
	read -a CONTROL <<< $(cat $PARSE_PATH$ANALYZER.txt)
	PARAMETERS="$DEF_PARAMs -r $ANALYZER"
	test_analyzer "$PARAMETERS"
}

ANALYZERS=(	"BLAST" "CBMC" "CPAchecker" "ESBMC" "FrankenBit" "LLBMC" "Predator" "Symbiotic" "UFO" "UltimateAutomizer" "UltimateKojak"	)

index=0

for ANALYZER in "${ANALYZERS[@]}"
do
	test
	index=$((index+1))
done

exit 1