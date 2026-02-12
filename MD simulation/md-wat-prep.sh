mkdir $1/wat_repeats
cp -r md_wat_prep/* $1/wat_repeats
cp $1/$1.inpcrd $1/wat_repeats/template
cp $1/$1-HMR.prmtop $1/wat_repeats/template
echo "
#!/bin/sh -f
#
#submit multiple repeat Amber simulations
#AJB 13/8/19
for I in {1..30}
do
echo \"BEGINNING \" \"\$I\"
cp -r template run\$I
cd run\$I
pwd
sbatch -p gpu --time=2-0:00 --job-name=$1_\$I --output=$1_\$I.runlog --gres=gpu:1 --ntasks=8 --nodes=1 --ntasks-per-core=1 -- ./runall-cMD-310K.sh $I
cd ..
done
" > $1/wat_repeats/multi_qsub.sh
chmod +x $1/wat_repeats/multi_qsub.sh
