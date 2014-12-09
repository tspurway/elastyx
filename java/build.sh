#!/bin/bash

cd "$(dirname "$0")"

rm -rf classes 2> /dev/null
rm elastyxOutput.jar 2> /dev/null

mkdir classes
javac -classpath `hadoop classpath`:org.json.jar -d classes *.java
jar -cvf elastyxOutput.jar -C classes/ .

