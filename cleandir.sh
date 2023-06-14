#!/bin/bash
for trash in $(find . -type f -name "*.OBJ" -o -name "*.EXE" -o -name "*.MAP"); do rm $trash; done;
