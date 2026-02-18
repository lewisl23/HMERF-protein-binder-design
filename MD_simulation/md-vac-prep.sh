mkdir $1/vac_repeats
cp -r md_vac_prep/* $1/vac_repeats
cp $1/$1_vac.inpcrd $1/vac_repeats/template
cp $1/$1_vac-HMR.prmtop $1/vac_repeats/template
echo "
#!/bin/sh -f
#
#submit multiple repeat Amber simulations
#AJB 13/8/19
for I in {1..5}
do
echo \"BEGINNING \" \"\$I\"
cp -r template run\$I
cd run\$I
pwd
qsub -V -h -p -\$I -q Gpus -cwd -N $2_\$I run-vacMD.sh \$I
cd ..
done
" > $1/vac_repeats/multi_qsub.sh
chmod +x $1/vac_repeats/multi_qsub.sh
