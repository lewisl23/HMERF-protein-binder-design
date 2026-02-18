
#!/bin/sh -f
#
#submit multiple repeat Amber simulations
#AJB 13/8/19
for I in {1..30}
do
echo "BEGINNING " "$I"
cp -r template run$I
cd run$I
pwd
sbatch -p gpu --time=2-0:00 --job-name=MWT_$I --output=MartinWT_$I.runlog --gres=gpu:1 --ntasks=8 --nodes=1 --ntasks-per-core=1 -- ./runall-cMD-310K.sh 
cd ..
done

