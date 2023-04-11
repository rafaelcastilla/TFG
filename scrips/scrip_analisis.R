directory = '/home/rafael/Downloads/scrips'
setwd(directory)
pacman::p_load(plyr,ggplot2,multcomp,lme4,pander,effects,readxl, dplyr,car)
brighData <- as.data.frame(read_xlsx('Brightness Induction/BrightnessInductionAll.xlsx'))

csData <- as.data.frame(read_xlsx('Center Surround/CenterSurroundAll.xlsx'))

####################\delta l
brighData$DeltaL=(brighData$FirstInducer- brighData$Test)
brighData[(brighData$Test==15),]$DeltaL=-1

brighData$DeltaL<-factor(brighData$DeltaL)
library(dplyr)
brighData$DeltaL <- recode_factor(brighData$DeltaL,"-1"="Control")

brighData$Induction <- (brighData$Comparison - brighData$Test)/(brighData$FirstInducer - brighData$Test)

######################

aux <- brighData %>% dplyr::group_by(Participant,DeltaL) %>% dplyr::summarise(MeanInduction=mean(Induction))
nParticipants <- length(unique(aux$Participant))

aux2 <- aux %>% dplyr::group_by(DeltaL) %>% dplyr::summarise(Induction=mean(MeanInduction), sem = sd(MeanInduction)/sqrt(nParticipants))

library(tidyverse)
library(RColorBrewer)


# Get palette:
cbPalette <- c("#999999", "#3E3E3E", "#DAA094", "#E54B2B", "#E49912", "#E3BA71", "#D55E00", "#338202", "#9FD47D", "#0293AB", "#023AAB", "#9D54DD", "#C965C9")

graf <- ggplot(aux2,aes(x=DeltaL, y=Induction)) +
  geom_bar(stat="identity", color="black", alpha=0.7, position="dodge", width=.5) +
  geom_errorbar(aes(ymin=Induction-sem, ymax=Induction+sem), width = 0.1, position=position_dodge(.5)) +
  scale_fill_manual(values=cbPalette) +
  xlab("") +
  ylab("Induction") +
  scale_y_continuous(breaks=seq(0,1,0.2), limits=c(0,0.8)) +
  theme_bw() +
  theme(text = element_text(size = 20),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(size = 0.5, colour = "black"),
        strip.text.x = element_text(color="black", size=22, angle=45),
        axis.title.x = element_text(size=22), axis.text.x = element_text(vjust=0.5, size=20),
        strip.text.y = element_text(color="black", size=22, angle=45),
        axis.title.y = element_text(size=22,vjust=2), axis.text.y  = element_text(vjust=0.5, size=20))

graf

ggsave("BrightnessInduction.png", plot = graf, device='png', dpi=150, width=7, height=4.5, units="in", bg="transparent")

#lo primero curioso es que hay mas induccion cuando 

#center surround

isoConditions <- csData[csData$MichelsonContrastInducer == 0,]


surrConditions <- df2 <- subset(csData, MichelsonContrastInducer != 0)

#mean 

meanIsoConditions <- isoConditions %>% dplyr::group_by(Participant) %>% dplyr::summarise(PerceivedContrast=mean(FinalMichelsonContrast))

meanSurrConditions <- surrConditions %>% dplyr::group_by(Participant,MichelsonContrastInducer) %>% dplyr::summarise(PerceivedContrast=mean(FinalMichelsonContrast))

meanSurrConditions$MichelsonContrastInducer <- factor(meanSurrConditions$MichelsonContrastInducer)
###################
participants <- unique(surrConditions$Participant)

# Initialize the suppression ratio column
meanSurrConditions$SuppressionRatio <- NaN

for (i in participants) {
  meanSurrConditions[meanSurrConditions$Participant==i,]$SuppressionRatio <- 1 - (meanSurrConditions[meanSurrConditions$Participant==i,]$PerceivedContrast / meanIsoConditions[meanIsoConditions$Participant==i,]$PerceivedContrast)
}

nParticipants <- length(participants)

aux <- meanSurrConditions %>% dplyr::group_by(MichelsonContrastInducer) %>% dplyr::summarise(MeanSuppressionRatio=mean(SuppressionRatio), sem = sd(SuppressionRatio)/sqrt(nParticipants))

library(tidyverse)
library(RColorBrewer)

# Get palette:
cbPalette <- c("#999999", "#3E3E3E", "#DAA094", "#E54B2B", "#E49912", "#E3BA71", "#D55E00", "#338202", "#9FD47D", "#0293AB", "#023AAB", "#9D54DD", "#C965C9")

graf <- ggplot(aux,aes(x=MichelsonContrastInducer, y=MeanSuppressionRatio)) +
  geom_bar(stat="identity", color="black", alpha=0.7, position="dodge", width=.5) +
  geom_errorbar(aes(ymin=MeanSuppressionRatio-sem, ymax=MeanSuppressionRatio+sem), width = 0.1, position=position_dodge(.5)) +
  scale_fill_manual(values=cbPalette) +
  xlab("") +
  ylab("Suppressio ratio") +
  scale_y_continuous(breaks=seq(0,1,0.2), limits=c(-0.1,0.5)) +
  theme_bw() +
  theme(text = element_text(size = 20),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(size = 0.5, colour = "black"),
        strip.text.x = element_text(color="black", size=22, angle=45),
        axis.title.x = element_text(size=22), axis.text.x = element_text(vjust=0.5, size=20),
        strip.text.y = element_text(color="black", size=22, angle=45),
        axis.title.y = element_text(size=22,vjust=2), axis.text.y  = element_text(vjust=0.5, size=20))

graf

ggsave("CenterSurround.png", plot = graf, device='png', dpi=150, width=7, height=4.5, units="in", bg="transparent")