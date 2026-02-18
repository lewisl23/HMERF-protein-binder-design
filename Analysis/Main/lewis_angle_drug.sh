# script to measure angle bending of Fn-3 domain bound to drug candidate.
cd ..
for I in martin-yasara*
do
for F in {1..10}
do
cpptraj << EOF
parm $I/wat_repeats/run$F/*.prmtop
trajin $I/wat_repeats/run$F/ntp*/cMD*.nc 1 last 1
strip :NA,CL,CA,WAT|@H=  
go
angle :55-149 :150-151 :153-155 out analysis/dcd/$I\_$F\_angle.dat range360
go
quit
EOF
done 
done

