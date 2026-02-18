mkdir $1
mkdir $1/setup
cp $1.pdb $1/setup
cd $1/setup
cp $1.pdb ..
pdb2pqr30 --titration-state-method propka --with-ph 7.4  --ff AMBER $1.pdb --ffout AMBER $1_reduced.pdb
echo "
source leaprc.protein.ff14SB
source leaprc.water.tip3p
source leaprc.phosaa14SB
loadAmberParams frcmod.ionsjc_tip3p
loadAmberParams frcmod.ions1lm_1264_tip3p
set default PBRadii mbondi3
x=loadpdb $1_reduced.pdb
check x
saveamberparm x $1_vac.prmtop $1_vac.inpcrd
savepdb x $1_amber-vac.pdb
solvateoct x TIP3PBOX 10 iso
charge x
savepdb x $1_amber.pdb
addionsrand x NA 0
addionsrand x CL 0
addionsrand x NA 58
addionsrand x CL 58
saveamberparm x $1.prmtop $1.inpcrd
quit" > leap.in
tleap -s -f leap.in
cat > parm.in <<EOF
HMassRepartition
outparm $1-HMR.prmtop
quit
EOF
parmed $1.prmtop -n < parm.in
cat > parm.in2 <<EOF2
HMassRepartition
outparm $1_vac-HMR.prmtop
quit
EOF2
parmed $1_vac.prmtop -n < parm.in2
cp $1.inpcrd ..
cp $1.prmtop ..
cp $1-HMR.prmtop ..
cp $1_vac.inpcrd ..
cp $1_vac-HMR.prmtop ..
cp $1_vac.prmtop ..
