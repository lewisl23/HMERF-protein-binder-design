#!/usr/bin/bash
./prephma.sh $1
./md-wat-prep.sh $1
cd $1/wat_repeats
./multi_qsub.sh
cd ../..


