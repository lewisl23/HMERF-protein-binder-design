# Data analysis for unbound MD simulation of Fn-3 domain
library(bio3d)
library(tidyverse)
library(Cairo)


#Store dcd and pdb files into variable
trajdcd_r <- list.files(pattern = "\\.dcd$")
numberpart <- as.numeric(gsub("[^0-9]", "", trajdcd_r))
trajdcd <- trajdcd_r[order(numberpart)]
trajpdb <- sub(".dcd",".pdb",trajdcd)
trajangle <- sub(".dcd","_angle.dat",trajdcd)
trajsasa <- sub(".dcd","_sasa.dat",trajdcd)
name <- sub(".*_", "", sub(".dcd", "", trajdcd))
order_level <- (1:length(trajdcd))
subject <- sub("_1.dcd", "", trajdcd[1])

trajdcd
trajpdb
trajangle

#Create data frame for plotting and set frame number
frame_len <- 9900
residue_len <- 192
RMSD_table <- data.frame(matrix(ncol = 0, nrow = frame_len))
RMSD_ab4_table <- data.frame(matrix(ncol = 0, nrow = 1))
RMSF_table <- data.frame(matrix(ncol = 0, nrow = residue_len))
bending_angle_table <- data.frame(matrix(ncol = 0, nrow = 1))
angle_table <-  data.frame(matrix(ncol = 0, nrow = 1))
sasa_table<-  data.frame(matrix(ncol = 0, nrow = 1))

#Set PDF size
CairoPDF("Analysis_Res_1_192", width = 7, height = 7)

for (data in 1:length(trajdcd)) {
  
  #Read pdb starting strcuture and dcd trajectory file
  pdb <- read.pdb(trajpdb[data])
  dcd <- read.dcd(trajdcd[data])
  simulation <- gsub(".dcd", "", trajdcd[data])
  run_no <-  sub(".*_", "", simulation)
  
  #Select all Ca atoms for trajectory frame supersition
  ca.inds <- atom.select(pdb, elety="CA")
  
  #Superimpose all Ca into xyz coordinate
  xyz <- fit.xyz(fixed=pdb$xyz, mobile=dcd, fixed.inds=ca.inds$xyz, mobile.inds=ca.inds$xyz)

  #RMSD
  #Calculate RMSD and write in dataframe
  rd <- rmsd(xyz[1,ca.inds$xyz], xyz[,ca.inds$xyz])
  #Write RMSD value into dataframe and change the column name
  RMSD_table <- cbind(RMSD_table, rd)
  colnames(RMSD_table)[data] <- run_no

  #Plot individual RMSD graph with average line
  plot(rd, typ="l", main=paste(simulation,"Mean =",mean(rd), sep = '_'), ylab="RMSD", xlab="Frame No.", ylim=c(0,15))
  print(mean(rd))
  print(sd(rd))
  points(lowess(rd), typ="l", col="red", lty=2, lwd=2)
  
  #Calculate the number of frame with RMSD above 4
  RMSD_ab4 <- sum(rd>4)
  RMSD_ab4_table <- cbind(RMSD_ab4_table, RMSD_ab4)
  colnames(RMSD_ab4_table)[data] <- run_no

  #RMSF
  #Calculate RMSF
  rf <- rmsf(xyz[,ca.inds$xyz])
  RMSF_table <- cbind(RMSF_table, rf)
  colnames(RMSF_table)[data] <- run_no
  plot(rf, main=paste(simulation,"RMSF"), ylab="RMSF", ylim=c(0,8), xlab="Residue Position", typ="l")
  
  
  #Read bending angle file and plot graph
  angle <- read.delim(trajangle[data], header = TRUE, nrows = frame_len, sep = "")
  angle_table <- cbind(angle_table, angle$range360)
  colnames(angle_table)[data] <- simulation
  
  angle_plot <- ggplot(data=angle, aes(x=X.Frame, y=range360, group=1)) +
                geom_line(color="red")+
                labs(x = "Frame", y = "Bending degree", title = paste("Bending angle of", simulation))+
                ylim(60,180)+
                ggtitle(paste(simulation,"Mean =",mean(angle$range360), sep = ' '))+
                theme(plot.title = element_text(hjust = 0.5))
  print(angle_plot)

  #Calculate the number of frame with bending angle above 140
  bending_angle <- sum(angle$range360<140)
  bending_angle_table <- cbind(bending_angle_table, bending_angle)
  colnames(bending_angle_table)[data] <- run_no
  
  
  #RMSD and angle plot
  rmsd_angle <- cbind(angle, rd)
  ylim.prim <- c(0, 15)   
  ylim.sec <- c(60, 180)
  b <- diff(ylim.prim)/diff(ylim.sec)
  a <- b*(ylim.prim[1] - ylim.sec[1])
  rmsd_angle_plot <- ggplot(rmsd_angle, aes(X.Frame, rd, group=1)) +
    geom_line(color="black")+
    geom_line(aes(y = a + range360*b), color = "red") +
    scale_y_continuous("RMSD", sec.axis = sec_axis(~ (. - a)/b, name = "Bending angle"),) +
    labs(x = "Frame No.", title = paste("RMSD and Bending angle of", simulation))+
    theme(plot.title = element_text(hjust = 0.5))
  print(rmsd_angle_plot)
  
  #Read sasa file
  sasa <- read.delim(trajsasa[data], header = TRUE, nrows = frame_len, sep = "")
  sasa_table <- cbind(sasa_table, sasa$MSURF_00001)
  colnames(sasa_table)[data] <- simulation
  
  #PCA plots
  pc <- pca.xyz(xyz[, ca.inds$xyz])
  plot(pc, col = bwr.colors(nrow(xyz)), main="PC Analysis")
  hc <- hclust(dist(pc$z[,1:2]))
  grps <- cutree(hc, k=2)
  plot(pc, col=grps, main="PC Analysis Regrouped")
  plot.bio3d(pc$au[,1], main="PC Analysis Combined", ylab="PC1 (A)", xlab="Residue Position", typ="l")
  points(pc$au[,2], typ="l", col="blue")
  p1 <- mktrj.pca(pc, pc=1, b=pc$au[,1], file=paste(simulation,"pc1.pdb", sep = ""))
  p2 <- mktrj.pca(pc, pc=2, b=pc$au[,2], file=paste(simulation,"pc2.pdb", sep = ""))
  
  #Find the frame number of the max and min of PCA
  min_frame_1 <- which.min(pc$z[,1])
  max_frame_1 <- which.max(pc$z[,1])
  
  min_frame_2 <- which.min(pc$z[,2])
  max_frame_2 <- which.max(pc$z[,2])
  
  print(paste(simulation,"completed"))
}


#Draw RMSD violin plot
RMSD_violin <- data_frame(Run = rep(c(name), each = frame_len),
                          RMSD = as.numeric(unlist(RMSD_table, use.name = FALSE)))
RMSD_violin$Run <- factor(RMSD_violin$Run, levels = order_level)


RMSD_violin_plot <- ggplot(RMSD_violin, aes(x=Run, y=RMSD, fill=Run)) +
  geom_violin(show.legend = FALSE) +
  stat_summary(fun="mean", geom="point", size=2, color="white", show.legend = FALSE)+
  geom_hline(yintercept=4, linetype = "dashed", color="red", linewidth=1)+
  geom_boxplot(width = 0.15, outlier.shape = NA, show.legend = FALSE)+
  labs(title = "Distribution of RMSD", subtitle = subject, x = "Run No.", y = "RMSD")+
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = (element_text(hjust = 0.5)))+
  ylim(0,18)
print(RMSD_violin_plot)

#Calclate RMSD above 4 into percentage
percentage_ab4 <- RMSD_ab4_table / frame_len*100
RMSD_ab4_table <- rbind(RMSD_ab4_table, percentage_ab4)

#Plot bar chart for RMSD vaue above 4
percentage_ab4_table <- data.frame(runname = name,
                                   percentage = as.numeric(percentage_ab4[1,]))
percentage_ab4_table$runname <- factor(percentage_ab4_table$runname, levels = order_level)
RMSD_percent_plot <- ggplot(percentage_ab4_table, aes(x=runname, y=percentage)) + 
                    geom_bar(stat = "identity")+
                    labs(title="RMSD > 4", subtitle = subject, x ="Run No.", y = "Percentage (%)")+
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = (element_text(hjust = 0.5)))+
                    ylim(0,100)
print(RMSD_percent_plot)

#Draw the angle violin plot
angle_violin <- data_frame(Run = rep(c(name), each = frame_len),
                          Bending_angle = as.numeric(unlist(angle_table, use.name = FALSE)))
angle_violin$Run <- factor(angle_violin$Run, levels = order_level)
angle_violin_plot <- ggplot(angle_violin, aes(x=Run, y=Bending_angle, fill=Run)) +
  geom_violin(show.legend = FALSE) +
  geom_hline(yintercept=142, linetype = "dashed", color="red", linewidth=1)+
  geom_boxplot(width = 0.15, outlier.shape = NA, show.legend = FALSE)+
  labs(title = "Bending angle of Fn-3 domain", subtitle = subject, x = "Run No.", y = "Angle")+
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = (element_text(hjust = 0.5)))+
  ylim(60,180)
print(angle_violin_plot)


#Calclate bending angle into percentage
percentage_angle <- bending_angle_table / frame_len*100

#Plot bar chart for bending angle percentage
percentage_angle_table <- data.frame(runname = name,
                                   percentage = as.numeric(percentage_angle[1,]))
percentage_angle_table$runname <- factor(percentage_angle_table$runname, levels = order_level)
bending_percent_plot <- ggplot(percentage_angle_table, aes(x=runname, y=percentage), xlab("Run"), 
                               ylab("Percentage (%)")) + 
  geom_bar(stat = "identity")+
  labs(title="Bending angle < 140", subtitle = subject, x ="Run No.", y = "Percentage (%)")+
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = (element_text(hjust = 0.5)))+
  ylim(0,100)
print(bending_percent_plot)

write.csv(angle_table, paste(subject,"angle.csv",sep = "_"), row.names=FALSE)
write.csv(RMSD_table, paste(subject,"rmsd.csv",sep = "_"), row.names=FALSE)
write.csv(sasa_table, paste(subject,"sasa.csv",sep = "_"), row.names=FALSE)

dev.off()




