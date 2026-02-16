#!/bin/bash
# Script used to textract basic RMSD, RMSF, and PCA data from MD trajectories using R and the bio3d package.
fred=*.dcd

for traj in $fred
do
pdb=${traj//".dcd"/".pdb"}
name=${traj//".dcd"/".pdf"}
title=${traj//".dcd"/""}
nonum=${title%?}
runnum=${title//$nonum/}
table=$nonum"_split_summary.dat"

echo "Processing parameter file: " $pdb
echo "Processing trajectory file: " $traj
echo "Output name: " $name

R --no-save << EOF
library(bio3d)
library(data.table)
library(Cairo)
CairoPDF("$name", width = 7, height = 7)
pdbf <- read.pdb("$pdb")
dcdf <- read.dcd("$traj")
ca.inds <- atom.select(pdbf, elety="CA")
xyz <- fit.xyz(fixed=pdbf\$xyz, mobile=dcdf, fixed.inds=ca.inds\$xyz, mobile.inds=ca.inds\$xyz)
rd <- rmsd(xyz[1,ca.inds\$xyz], xyz[,ca.inds\$xyz])
plot(rd, typ="l", main=paste("Mean =",mean(rd)), ylab="RMSD", xlab="Frame No.", ylim=c(0,8))
print(mean(rd))
points(lowess(rd), typ="l", col="red", lty=2, lwd=2)
hist(rd, breaks=40, freq=FALSE, main=paste("$title","RMSD Histogram"), xlab="RMSD", xlim=c(0,8))
lines(density(rd), col="gray", lwd=3)
rf <- rmsf(xyz[,ca.inds\$xyz])
plot(rf, main=paste("$title","RMSF"), ylab="RMSF", ylim=c(0,8), xlab="Residue Position", typ="l")
pc <- pca.xyz(xyz[, ca.inds\$xyz])
plot(pc, col = bwr.colors(nrow(xyz)), main=paste("$title","PC Analysis"))
hc <- hclust(dist(pc\$z[,1:2]))
grps <- cutree(hc, k=2)
plot(pc, col=grps, main=paste("$title","PC Analysis Regrouped"))
plot.bio3d(pc\$au[,1], main=paste("$title","PC Analysis Combined"), ylab="PC1 (A)", xlab="Residue Position", typ="l")
points(pc\$au[,2], typ="l", col="blue")
p1 <- mktrj.pca(pc, pc=1, b=pc\$au[,1], file=paste("$title","pc1.pdb", sep = ""))
p2 <- mktrj.pca(pc, pc=2,b=pc\$au[,2], file=paste("$title","pc2.pdb", sep = ""))
cij<-dccm(xyz[,ca.inds\$xyz])
plot(cij, main=paste("$title","Cross Correlations"),)
dev.off()
EOF
done
mkdir -p ../pdfs
mv *.pdf ../pdfs/ 
