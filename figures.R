# Script used to create visualisations for the bending angle and RMSD.
library(tidyverse)
library(Cairo)
library(plotrix)
library(multcomp)
library(forcats)
library(car)


angle_list <- list.files(pattern = "angle\\.csv$")
rmsd_list <- sub("angle.csv","rmsd.csv",angle_list)
angle_table <- data.frame(matrix(ncol = 0, nrow = 30000))
rmsd_table <- data.frame(matrix(ncol = 0, nrow = 30000))
angle_stat <- data.frame(Run = character(), Mean = numeric(),
                        Stdev = numeric(), Stder = numeric(),
                        stringsAsFactors = FALSE)
rmsd_stat <- data.frame(Run = character(), Mean = numeric(),
                         Stdev = numeric(), Stder = numeric(),
                         stringsAsFactors = FALSE)
bending_angle_table <- data.frame(matrix(ncol = 0, nrow = 1))

breaks <- seq(from = 60, to = 180, by = 5)
level = c("Wildtype", "Mutant")

#Set PDF size
CairoPDF("Stat_analysis_ori", width = 7, height = 7)


for (data in 1:length(angle_list)) {
  #Read the angle file and save it into data frame
  angle_data <- read.csv(angle_list[data])
  angle_data <- tail(angle_data, 1000)
  subject <- sub("_angle.csv", "", angle_list[data])
  angle_data <- unlist(angle_data, use.names = FALSE)
  angle_table <- cbind(angle_table,angle_data)
  colnames(angle_table)[data] <- subject
  
  #Read the rmsd file and save it into data frame
  rmsd_data <- read.csv(rmsd_list[data])
  rmsd_data <- tail(rmsd_data, 1000)
  rmsd_data <- unlist(rmsd_data, use.names = FALSE)
  rmsd_table <- cbind(rmsd_table,rmsd_data)
  colnames(rmsd_table)[data] <- subject
  
  #Calculate the mean, standard deviation, and standard error
  mean <- mean(angle_data)
  stdev <- sd(angle_data)
  stderr <- std.error(angle_data)
  angle_stat <- rbind(angle_stat, data.frame(subject, mean, stdev, stderr),
                    stringsAsFactors = FALSE)
  
  #Calculate the number of frame with bending angle above 142
  bending_angle <- sum(angle_data<142)
  bending_angle_table <- cbind(bending_angle_table, bending_angle)
  colnames(bending_angle_table)[data] <- subject
  
  
  #Plot a histogram for the bending angle for each variable
  histogram_angle <- hist(angle_data, xlim=c(60,180), ylim = c(0,100000), breaks = breaks,
                    main = paste("Bending angle of", subject, sep = " "),
                    xlab = "Angle (degree)")
  print(histogram_angle)
  
  #Plot a histogram for the rmsd for each variable
  histogram_rmsd <- hist(rmsd_data, xlim=c(0,20), ylim = c(0,50000), 
                    breaks = seq(from = 0, to = 150, by = 0.5),
                    main = paste("RMSD of", subject, sep = " "),
                    xlab = "RMSD")
  print(histogram_rmsd)
  
}


#Violin plot of RMSD distribution
rmsd_violin_table <- data.frame(group = rep(c("Wildtype", "Mutant"), each = 30000),
                            rmsd = c(rmsd_table$Wildtype, rmsd_table$Mutant))
rmsd_violin_table$group <- factor(rmsd_violin_table$group, levels = level)
rmsd_violin_plot <- ggplot(rmsd_violin_table, aes(x=group, y=rmsd, fill=group)) +
  geom_violin(show.legend = FALSE) +
  geom_hline(yintercept=4, linetype = "dashed", color="red", linewidth=1)+
  geom_boxplot(width = 0.1, outlier.shape = NA, show.legend = FALSE)+
  labs(title = "RMSD of Fn3-119", x = "Group", y = "RMSD")+
  theme(plot.title = element_text(hjust = 0.5),
        axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1))+
  ylim(0,20)
print(rmsd_violin_plot)

#Levels for the x-axis             
angle_stat$subject <- factor(angle_stat$subject, 
            levels = c("Wildtype", "Mutant"))

#Plot the mean of bending angles and standard deviation
angle_bar <- ggplot(angle_stat, aes(x = subject, y = mean, fill = subject)) +
              geom_bar(stat = "identity", show.legend = FALSE) +
              scale_y_continuous(breaks = seq(from = 110, to = 180, by = 10))+
              labs(title = "Titin Fn3-119 Average Bending Angle",
                x = "" ,  y = "Angle (degree)") +
              geom_errorbar(aes(ymin = mean - stdev, ymax = mean + stdev),
                position = position_dodge(width = 0.75), width = 0.25)+
               theme_bw()+
              theme(plot.title = element_text(hjust = 0.5),
                    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1)) +
              coord_cartesian(ylim = c(110,180))
print(angle_bar)

#Violin plot of bending angle distribution
bending_violin_table <- data.frame(group = rep(c("Wildtype", "Mutant"), each = 30000),
                                angle = c(angle_table$Wildtype,angle_table$Mutant))
bending_violin_table$group <- factor(bending_violin_table$group, levels = level)
bending_violin_plot <- ggplot(bending_violin_table, aes(x=group, y=angle, fill=group)) +
  geom_violin(show.legend = FALSE) +
  scale_y_continuous(limits = c(60,180) ,breaks = seq(from = 60, to = 180, by = 20))+
  geom_hline(yintercept=158, linetype = "dashed", color="blue", linewidth=1)+
  geom_hline(yintercept=146, linetype = "dashed", color="red", linewidth=1)+
  geom_hline(yintercept=142, linetype = "dashed", color="green", linewidth=1)+
  geom_boxplot(width = 0.075, outlier.shape = NA, show.legend = FALSE)+
  labs(title = "Titin Fn3-119 Bending Angle", x = "Group", y = "Angle (degree)")+
  theme(plot.title = element_text(hjust = 0.5),
        axis.text.x = element_text(angle = 45, hjust = 0.75, vjust = 0.5))
print(bending_violin_plot)

#Calculate bending angle into percentage
percentage_angle <- bending_angle_table / 30000*100

#Plot bar chart for bending angle percentage
percentage_angle_table <- data.frame(runname = c("Wildtype", "Mutant"),
                                     percentage = c(percentage_angle$Wildtype, percentage_angle$Mutant))
percentage_angle_table$runname <- factor(percentage_angle_table$runname, levels = level)
bending_percent_plot <- ggplot(percentage_angle_table, aes(x=runname, y=percentage)) + 
  geom_bar(stat = "identity")+
  labs(title="Fn3-119 Bending angle < 142", x = "Group", y = "Percentage (%)")+
  geom_hline(yintercept=5, linetype = "dashed", color="blue", linewidth=1)+
  geom_hline(yintercept=44, linetype = "dashed", color="red", linewidth=1)+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5),
        axis.text.x = element_text(angle = 45, hjust = 0.75, vjust = 0.8))+
  ylim(0,100)
print(bending_percent_plot)


dev.off()

