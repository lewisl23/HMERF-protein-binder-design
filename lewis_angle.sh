# script to measure angle bending of unbound Fn-3 domain
cd ..
for I in Martin*
do
for F in {1..5}
do
cpptraj << EOF
parm $I/wat_repeats/run$F/*.prmtop
trajin $I/wat_repeats/run$F/ntp*/cMD*.nc 1 last 1
strip :NA,CL,CA,WAT|@H=  
go
angle :2-96 :97-98 :99-101 out analysis/dcd/$I\_$F\_angle.dat range360
go
quit
EOF
done 
done

