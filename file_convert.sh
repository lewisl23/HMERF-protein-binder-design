#script to get dcds and pdb from the prmtops and ncs
cd ..
for I in Ma*
do
for F in {1..5}
do
cpptraj << EOF
parm $I/wat_repeats/run$F/*.prmtop
trajin $I/wat_repeats/run$F/ntp*/cMD*.nc 1 last 1
strip :NA,CL,WAT|@H=  
trajout analysis/CA_end_pdb/$I\_$F.pdb onlyframes 100
go
strip :NA,CL,CA,WAT|@H= parmout analysis/dcd/$I\_$F.prmtop 
autoimage
trajout analysis/dcd/$I\_$F.dcd start 100
trajout analysis/dcd/$I\_$F.xtc start 100
trajout analysis/dcd/$I\_$F.pdb onlyframes 1
go
quit
EOF
done 
done

