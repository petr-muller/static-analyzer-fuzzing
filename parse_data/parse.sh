#!/bin/bash

SOURCE="$1"
SVC_PATH="/home/shooter/GIT/svcomp/"


if [ ! -f "$SOURCE" ]
then
   echo "Cannot open input file." >&2
   exit 0
fi


FILES=(
	"ldv-linux-3.0/module_get_put-drivers-net-pppox.ko_true.cil.out.i.pp.i"
	"ldv-linux-3.4-simple/32_1_cilled_true_ok_nondet_linux-3.4-32_1-drivers--ata--pata_marvell.ko-ldv_main0_sequence_infinite_withcheck_stateful.cil.out.c"
	"ldv-linux-3.4-simple/32_1_cilled_true_ok_nondet_linux-3.4-32_1-drivers--ata--pata_netcell.ko-ldv_main0_sequence_infinite_withcheck_stateful.cil.out.c"
	"ldv-linux-3.0/module_get_put-drivers-block-drbd-drbd.ko_false.cil.out.i.pp.i"
	"ldv-linux-3.4-simple/32_7_cilled_false_const_ok_linux-32_1-drivers--isdn--capi--kernelcapi.ko-ldv_main3_sequence_infinite_withcheck_stateful.cil.out.c"
	"ldv-linux-3.4-simple/32_1_cilled_true_ok_nondet_linux-3.4-32_1-drivers--watchdog--iTCO_vendor_support.ko-ldv_main0_sequence_infinite_withcheck_stateful.cil.out.c"
	)

ANALYZERS=(
						#stlpce v poradi (na 0. je PATHs)
	"BLAST"				#1. stlpec je BLAST
	"CBMC" 				#2. stlpec je CBMC
	"CPAchecker"		#3. stlpec je CPAchecker
	"ESBMC"
	"FrankenBit"
	"LLBMC"			#6. stlpec je LLBMC
	"Predator" 			#7. stlpec je Predator
	"Symbiotic"
	"UFO"
	"UltimateAutomizer"
	"UltimateKojak"
	)

CompLIST="complete_list.txt"
LIST="LIST.txt"
PATHs="PATHs.txt"

TEMP=$(mktemp)

cat "$SOURCE" | sed -e "s/out of memory/ERR/g" | sed -e "s/exception (gremlins)/ERR/g" | sed -e "s/error (recursion)/ERR/g" \
| awk -v path="$SVC_PATH" '{ print path$1" "$2" "$5" "$8" "$11" "$14" "$17" "$20" "$23" "$26" "$29" "$32  }' > "$CompLIST"

#
#cat "$CompLIST" | awk '{ print $1 }' > ./parse_data/source_paths.txt
#

FILES_LIST=$(echo "${FILES[@]}" | sed -e "s/ /|/g")

cat "$CompLIST" | grep -E "$FILES_LIST" | sed -e "s/false(label)/FALSE/g" | tee "$TEMP" \
| awk '{ print $1 }' > "$PATHs"

cat "$TEMP" | sed -e "s/true/TRUE/g" | sed -e "s/false/FALSE/g" | sed -e "s/unknown/UNKNOWN/g" \
| sed -e "s/timeout/TIMEOUT/g" > "$LIST"


index=2

for analyzer in "${ANALYZERS[@]}"
do
	OUT_FILE="${ANALYZERS[$((index-2))]}.txt"
	#echo -e "$OUT_FILE"
	cat "$LIST" | awk -v i="$index" '{ print $i }' > $OUT_FILE

	index=$((index+1))
done


rm -f "$CompLIST" "$TEMP"
exit 1
