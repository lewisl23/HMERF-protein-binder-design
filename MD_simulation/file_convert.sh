#script to get dcd/xtc and pdb from the prmtops and ncs
# NOTE: this script starts at frame 100 to ensure that simualtion energy stabalises 

cd ..
for I in Martin*
do
for F in {1..30}
do
cpptraj << EOF
parm $I/wat_repeats/run$F/*.prmtop
trajin $I/wat_repeats/run$F/ntp*/cMD*.nc 101 last 1
strip :NA,CL,WAT|@H=  
trajout analysis/CA_end_pdb/$I\_$F.pdb onlyframes 1
go
strip :NA,CL,CA,WAT|@H= parmout analysis/dcd/$I\_$F.prmtop 
autoimage
trajout analysis/dcd/$I\_$F.dcd start 1
trajout analysis/dcd/$I\_$F.xtc start 1
trajout analysis/dcd/$I\_$F.pdb onlyframes 1
go
quit
EOF
done 
done

