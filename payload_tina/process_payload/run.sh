#!/bin/sh

INPUT_DIR=$1
OUTPUT_DIR=$2

find $INPUT_DIR -name '*.zip' -exec sh -c 'unzip -d `dirname {}` {}' ';'

tina_exe=$(find /opt -name 'tina' 2>&1)

cd $INPUT_DIR

$tina_exe $(cat cli_parameters.txt) &> ../$OUTPUT_DIR/outfile ../$OUTPUT_DIR/digestfile ../$OUTPUT_DIR/errorfile


cp ./*.txt ../$OUTPUT_DIR
# --- EOF ---
