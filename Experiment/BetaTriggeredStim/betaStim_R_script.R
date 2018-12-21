# ------------------------------------------------------------------------

setwd('C:/Users/david/SharedCode/MATLAB_ECoG_code/Experiment/BetaTriggeredStim/')

library('Hmisc')
#library('nlme')
library('ggplot2')
#library('drc')
#library('minpack.lm')
#library('lmtest')
library('glmm')
library("lme4")
library('multcomp')
library('plyr')
library('here')
library('lmerTest')
library('sjPlot')
library('emmeans')

rootDir = here()

savePlot = 0
figWidth = 8 
figHeight = 6 

# ------------------------------------------------------------------------

data <- read.table(here("Experiment","BetaTriggeredStim","betaStim_outputTable_50.csv"),header=TRUE,sep = ",",stringsAsFactors=F,
                   colClasses=c("magnitude"="numeric","betaLabels"="factor","sid"="factor","numStims"="factor","stimLevel"="numeric","channel"="factor","subjectNum"="factor","phaseClass"="factor","setToDeliverPhase"="factor"))
data <- subset(data, magnitude<1500)
data <- subset(data, magnitude>25)

data <- subset(data,!is.nan(data$magnitude))
data <- subset(data,data$sid!='702d24')
data <- subset(data,data$sid!='0b5a2ePlayBack')
data <- subset(data,data$numStims!='Null')
# rename for ease
data$numStims <- revalue(data$numStims, c("Test 1"="[1,2]","Test 2"="[3,4]","Test 3"="[5,inf)"))
#data$phaseClass <- revalue(data$phaseClass, c("90"=0,"270"=1))

data$percentDiff = 0
for (name in unique(data$sid)){
  for (chan in unique(data[data$sid == name,]$channel)){
    for (numStimTrial in unique(data$numStims)){
      numBase = nrow(data[data$sid == name & data$channel == chan & data$numStims == 'Base',])
      base = data[data$sid == name & data$channel == chan & data$numStims == 'Base',]$magnitude
      baseMean = mean(base)
      data[data$sid == name & data$channel == chan & data$numStims == 'Base',]$percentDiff = 100*(base - baseMean)/baseMean
      for (typePhase in unique(data$phaseClass)){
        percentDiff = 100*((data[data$sid == name & data$channel == chan & data$numStims == numStimTrial & data$phaseClass == typePhase,]$magnitude)-baseMean)/baseMean
        data[data$sid == name & data$channel == chan & data$numStims == numStimTrial & data$phaseClass == typePhase,]$percentDiff = percentDiff
      }
    }
  }
}

sapply(data,class)
#summaryData = ddply(data[data$numStims != "Base",] , .(sid,phaseClass,numStims,channel), function(x) mean(x[,"percentDiff"]))

# confirm nothing below 150 uV 
summaryData = ddply(data, .(sid,phaseClass,numStims,channel,betaLabels), summarize, magnitude = mean(magnitude))

summaryData = ddply(data[data$numStims != "Base",] , .(sid,phaseClass,numStims,channel,betaLabels), summarize, percentDiff = mean(percentDiff))

dataNoBaseline = data[data$numStims != "Base",]
dataSubjOnly <- subset(data,data$sid=='0b5a2e')


# ------------------------------------------------------------------------


#data <- read.table(here("Experiment","BetaTriggeredStim","betaStim_outputTable.csv"),header=TRUE,sep = ",",stringsAsFactors=F)
ggplot(data, aes(x=magnitude)) + 
  geom_histogram(binwidth=100)

# # Change box plot colors by groups
# ggplot(data, aes(x=numStims, y=magnitude, fill=phaseClass)) +
#   geom_boxplot()
# Change the position
p<-ggplot(data, aes(x=numStims, y=magnitude, fill=phaseClass)) +
  geom_boxplot(position=position_dodge(1))
p

# Change box plot colors by groups
# ggplot(summaryData, aes(x=numStims, y=percentDiff,fill=phaseClass)) +
#   geom_boxplot(notch=TRUE)
# Change the position
p<-ggplot(summaryData, aes(x=numStims, y=percentDiff,fill=phaseClass)) +
  geom_boxplot(notch=TRUE,position=position_dodge(1)) +
  geom_hline(yintercept=0)
p

p2 <- ggplot(summaryData, aes(x=numStims, y=percentDiff,fill=phaseClass)) + theme_classic(base_size = 18) +
  geom_dotplot(binaxis='y',binwidth=2,stackdir='center', 
               position=position_dodge(0.8)) +
  geom_pointrange(mapping = aes(x = numStims, y = percentDiff,color=phaseClass),
                  stat = "summary",
                  fun.ymin = function(z) {quantile(z,0.25)},
                  fun.ymax = function(z) {quantile(z,0.75)},
                  fun.y = median,
                  position=position_dodge(0.8),size=1.2,color="black",show.legend = FALSE) +  
  labs(x = 'Number of conditioning stimuli',colour = 'delivered phase',title = 'Dose dependence as a function of phase of stimulation',y = 'Percent difference from baseline')+ 
  geom_hline(yintercept=0) 
p2

pd1 = position_dodge(0.2)
pd2 = position_dodge(0.65)

p2 <- ggplot(summaryData, aes(x=numStims, y=percentDiff,color=phaseClass)) + theme_light(base_size = 18) +
  geom_point(position=position_jitterdodge(dodge.width=0.65, jitter.height=0, jitter.width=0.25),
             alpha=0.7) +
  stat_summary(fun.data=mean_cl_boot, geom="errorbar", width=0.05, position=pd1) +
  stat_summary(fun.y=mean, geom="point", size=2, position=pd1) +  
  labs(x = 'Number of conditioning stimuli',colour = 'delivered phase',title = 'Dose dependence as a function of phase of stimulation',y = 'Percent difference from baseline')+ 
  geom_hline(yintercept=0) 
p2

pd1 = position_dodge(0.2)
pd2 = position_dodge(0.65)

p2 <- ggplot(summaryData, aes(x=numStims, y=percentDiff,color=phaseClass)) + theme_light(base_size = 18) +
  geom_point(position=position_jitterdodge(dodge.width=0.65, jitter.height=0, jitter.width=0.25),
             alpha=0.7) +
  stat_summary(fun.data=median_hilow,fun.args=(conf.int =0.5), geom="errorbar", width=0.05, position=pd1) +
  stat_summary(fun.y=median, geom="point", size=2, position=pd1) +  
  labs(x = 'Number of conditioning stimuli',colour = 'delivered phase',title = 'Dose dependence as a function of phase of stimulation',y = 'Percent difference from baseline')+ 
  geom_hline(yintercept=0) +
  scale_color_hue(labels=c("depolarizing", "hyperpolarizing")) 
p2



p2 <- ggplot(summaryData, aes(x=numStims, y=percentDiff,fill=phaseClass)) + 
  geom_boxplot(mapping = aes(x = numStims, y = percentDiff,fill=phaseClass),
               position=position_dodge(0.8),notch=TRUE)  + 
  geom_dotplot(binaxis='y',binwidth=2,stackdir='center', 
               position=position_dodge(0.8))+
  labs(x = 'Number of conditioning stimuli',colour = 'delivered phase',title = 'Dose dependence as a function of phase of stimulation',y = 'Percent difference from baseline')

p2 
p2 + geom_hline(yintercept=0) + theme_classic()

# ------------------------------------------------------------------------


#fit.glm    = glm(magnitude ~ stimLevel + numStims + subjectNum + channel + phaseClass,data=data)
#fit.glm    = glm(magnitude ~ numStims + channel + phaseClass,data=data)
fit.glm    = glm(percentDiff ~ numStims+phaseClass+betaLabels+channel,data=dataNoBaseline)
fit.glm    = glm(percentDiff ~ numStims+phaseClass+betaLabels,data=dataNoBaseline)

summary(fit.glm)
plot(fit.glm)
summary(glht(fit.glm,linfct=mcp(phaseClass="Tukey")))
summary(glht(fit.glm,linfct=mcp(numStims="Tukey")))

p <- ggplot(dataNoBaseline, aes(x=numStims, y=percentDiff, colour=phaseClass)) +
  geom_point(size=3) +
  geom_line(aes(y=predict(fm2), group=Subject, size="Subjects")) +
  geom_line(data=newdat, aes(y=predict(fm2, level=0, newdata=newdat), size="Population")) +
  scale_size_manual(name="Predictions", values=c("Subjects"=0.5, "Population"=3)) +
  theme_bw(base_size=22) 
print(p)

p2 <- ggplot(dataNoBaseline, aes(x=numStims, y=percentDiff,fill=phaseClass)) + theme_classic(base_size = 18) +
  geom_boxplot(binaxis='y',binwidth=2,stackdir='center', 
               position=position_dodge(0.8)) +
  geom_dotplot(data = dataNoBaseline, aes(y=predict(fit.lmm2,level=0,newdata = dataNoBaseline))) +
  labs(x = 'Number of conditioning stimuli',colour = 'delivered phase',title = 'Dose dependence as a function of phase of stimulation',y = 'Percent difference from baseline')+ 
  geom_hline(yintercept=0) 
p2

#fit.glm    = glm(magnitude ~ stimLevel + numStims + subjectNum + channel + phaseClass,data=data)
#fit.glm    = glm(magnitude ~ numStims + channel + phaseClass,data=data)
fit.glm2    = glm(magnitude ~ numStims+phaseClass+betaLabels,data=data)

summary(fit.glm2)
plot(fit.glm2)
summary(glht(fit.glm2,linfct=mcp(phaseClass="Tukey")))
summary(glht(fit.glm2,linfct=mcp(numStims="Tukey")))


#fit.lmm = lmer(magnitude ~ stimLevel + numStims + subjectNum + channel + phaseClass + (1|subjectNum) + (1|numStims) + (1|channel)+(1|stimLevel),data=data)
fit.lmm = lmer(percentDiff~numStims+phaseClass+betaLabels+channel+ (1| sid) ,data=dataNoBaseline)
summary(fit.lmm)
plot(fit.lmm)
#confint(fit.lmm,method="boot")
summary(glht(fit.lmm,linfct=mcp(numStims="Tukey")))
summary(glht(fit.lmm,linfct=mcp(betaLabels="Tukey")))
summary(glht(fit.lmm,linfct=mcp(phaseClass="Tukey")))

fit.lmm2 = lmer(percentDiff~numStims+phaseClass+betaLabels + numStims * phaseClass + (1 | sid/channel) ,data=dataNoBaseline)
fit.lmm2 = lmer(percentDiff~numStims+phaseClass+betaLabels  + (1 | sid/channel)  ,data=dataNoBaseline)

RIaS = unlist(ranef(fit.lmm2))
FixedEff = fixef(fit.lmm2)
summary(fit.lmm2)
#fit.lmm2 = lmer(percentDiff~numStims+phaseClass+betaLabels + (1 + numStims|sid/channel) + (phaseClass|sid/channel) ,data=dataNoBaseline)
plot(fit.lmm2)
qqnorm(resid(fit.lmm2))
qqline(resid(fit.lmm2))  #summary(fit.lmm2)
#confint(fit.lmm2,method="boot")
summary(glht(fit.lmm2,linfct=mcp(numStims="Tukey")))
summary(glht(fit.lmm2,linfct=mcp(betaLabels="Tukey")))
summary(glht(fit.lmm2,linfct=mcp(phaseClass="Tukey")))

#
############ BEST ONE RIGHT NOW
fit.lmm3 = lme4::lmer(percentDiff~numStims+phaseClass + betaLabels + + numStims*betaLabels + numStims*phaseClass + (1 | sid/channel) ,data=summaryData)
#fit.lmm3 = lmerTest::lmer(percentDiff~numStims+phaseClass + betaLabels + (1 | sid/channel) ,data=dataNoBaseline)

fit.lmm3 = lmerTest::lmer(percentDiff~numStims+phaseClass + betaLabels  + numStims*betaLabels + numStims*phaseClass + (1 | sid/channel) ,data=dataNoBaseline)
RIaS = unlist(ranef(fit.lmm3))
FixedEff = fixef(fit.lmm3)
emm_s.t <- emmeans(fit.lmm3, pairwise ~ numStims | phaseClass)
emm_s.t <- emmeans(fit.lmm3, pairwise ~ numStims | betaLabels)
anova(fit.lmm3)



tab_model(
  m1, m2, 
  pred.labels = c("Intercept", "Age (Carer)", "Hours per Week", "Gender (Carer)",
                  "Education: middle (Carer)", "Education: high (Carer)", 
                  "Age (Older Person)"),
  dv.labels = c("First Model", "M2"),
  string.pred = "Coeffcient",
  string.ci = "Conf. Int (95%)",
  string.p = "P-Value"
)

tab_model(fit.lmm3)

summary(fit.lmm3)
plot(fit.lmm3)
qqnorm(resid(fit.lmm3))
qqline(resid(fit.lmm3))  #summary(fit.lmm2)
summary(glht(fit.lmm3,linfct=mcp(numStims="Tukey")))
summary(glht(fit.lmm3,linfct=mcp(betaLabels="Tukey")))
summary(glht(fit.lmm3,linfct=mcp(phaseClass="Tukey")))

fit.lmm4 = lmer(percentDiff~numStims+phaseClass + betaLabels +  (1 | channel) ,data=dataSubjOnly)
summary(fit.lmm4)
qqnorm(resid(fit.lmm4))
qqline(resid(fit.lmm4))  #summary(fit.lmm2)
summary(glht(fit.lmm4,linfct=mcp(numStims="Tukey")))
summary(glht(fit.lmm4,linfct=mcp(betaLabels="Tukey")))
summary(glht(fit.lmm4,linfct=mcp(phaseClass="Tukey")))

# xtra ss test
anova(fit.glm, fit.lmm,fit.lmm2)
# Likelihood ratio test

lrtest(fit.glm,fit.lmm,fit.lmm2)

# aic
AIC(fit.glm,fit.lmm,fit.lmm2)

BIC(fit.glm,fit.lmm,fit.lmm2)

for (chanInt in chanIntVec){
  
  dataInt <- na.exclude(subset(dataPP,(chanVec == chanInt) & (blockVec %in% blockIntPlot)))
  
  p <- ggplot(dataInt, aes(x=stimLevelVec, y=PPvec,colour=stimLevelVec)) + 
    geom_jitter(width=35) +  geom_smooth(method=lm) + facet_wrap(~blockVec, labeller = as_labeller(blockNames))+
    labs(x = expression(paste("Stimulation current ",mu,"A")),y=expression(paste("Peak to Peak magnitude ",mu,"V"), fill="stimulus level"),title = paste0("Subject ", subjectNum, " ID ", sid," DBS Paired Pulse EP Measurements")) +
    guides(colour=guide_legend("stimulation level"))
  print(p)
  
  if (savePlot && !avgMeas) {
    ggsave(paste0("subj_", subjectNum, "_ID_", sid,"_scatter_lm.png"), units="in", width=figWidth, height=figHeight, dpi=600)
  }
  else if (savePlot && avgMeas){
    ggsave(paste0("subj_", subjectNum, "_ID_", sid,"_scatter_lm_avg.png"), units="in", width=figWidth, height=figHeight, dpi=600)
  }
  
  dataToFit <- na.exclude(dataPP[dataPP$blockVec %in% blockIntLM & dataPP$chanVec==chanInt,])
  fit.glm    = glm(PPvec ~ blockVec + stimLevelVec,data=dataToFit)
  summary(fit.glm)
  summary(glht(fit.glm,linfct=mcp(blockVec="Tukey")))
  # plot(fit.glm)
  
  # fit.lmm = lmer(PPvec ~ stimLevelVec + blockVec + (1|stimLevelVec) + (1|blockVec), data=dataToFit)
  # summary(fit.lmm)
  #confint(fit.lmm,method="boot")
  
  # get starting values
  if (sid != '8e907') {
    fit.startnlme0 <- nlsLM(PPvec ~ SSlogis(stimLevelVec, Asym, xmid, scal),data=dataToFit)
  } else {
    fit.startnlme0 <- nlsLM(PPvec ~ SSlogis(stimLevelVec, Asym, xmid, scal),data=dataToFit,start = c(Asym=400,xmid = 500,scal = 500),control = list(maxiter = 500))
  }
  
  startVals = summary(fit.startnlme0)$coefficients
  # 
  #  if (sid == '08b13') {
  #    fit.nlme0 <- gnls(PPvec ~ SSlogis(stimLevelVec, Asym, xmid, scal),data=dataToFit,
  #                      start=list(Asym=startVals[1,1]+200,xmid=startVals[2,1],scal=startVals[3,1]))
  #  }else if (sid=='8e907') {
  #    fit.nlme0 <- gnls(PPvec ~ SSlogis(stimLevelVec, Asym, xmid, scal),data=dataToFit,
  #                      start=list(Asym=startVals[1,1]+200,xmid=startVals[2,1],scal=startVals[3,1]),control = list(maxiter = 500))
  #  }else {
  #    fit.nlme0 <- gnls(PPvec ~ SSlogis(stimLevelVec, Asym, xmid, scal),data=dataToFit,
  #                      start=list(Asym=startVals[1,1]+200,xmid=startVals[2,1],scal=startVals[3,1]))
  #  }
  # 
  #  #Create a range of doses:
  #  stimLevelVecNew <- data.frame(stimLevelVec = seq(min(dataToFit$stimLevelVec), max(dataToFit$stimLevelVec), length.out = 200))
  #  #Create a new data frame for ggplot using predict and your range of new
  #  #doses:
  #  predData=data.frame(PPvec=predict(fit.nlme0,newdata=stimLevelVecNew),stimLevelVec=stimLevelVecNew)
  # 
  #  p3 <- ggplot(dataToFit, aes(x=stimLevelVec, y=PPvec,colour=stimLevelVec)) +
  #    geom_jitter(width=35) +
  #    facet_wrap(~blockVec, labeller = as_labeller(blockNames))+
  #    labs(x = expression(paste("Stimulation current ",mu,"A")),y=expression(paste("Peak to Peak magnitude ",mu,"V"), fill="stimulus level"),title = paste0("Subject ", subjectNum, " ID ", sid," DBS Paired Pulse EP Measurements")) +
  #    guides(colour=guide_legend("stimulation level"))+ geom_line(data=predData,aes(x=stimLevelVec,y=PPvec),size=2,colour='black')
  #  print(p3)
  # 
  #  if (savePlot && !avgMeas) {
  #    ggsave(paste0("subj_", subjectNum, "_ID_", sid,"_scatter_sameModel.png"), units="in", width=figWidth, height=figHeight, dpi=600)
  #  }
  #  else if (savePlot && avgMeas){
  #    ggsave(paste0("subj_", subjectNum, "_ID_", sid,"_scatter_sameModel_avg.png"), units="in", width=figWidth, height=figHeight, dpi=600)
  # 
  #  }
  
  fit.nlme1 <- nlme(PPvec ~ SSlogis(stimLevelVec, Asym, xmid, scal),
                    fixed=list(Asym ~ blockVec, xmid + scal ~ 1),
                    random = scal ~ 1|blockVec,
                    start=list(fixed=c(Asym=rep(startVals[1,1]+200,length(blockIntLM)),xmid=startVals[2,1],scal=startVals[3,1])),
                    data=dataToFit)
  
  # vs.   fixed=list(Asym ~ blockVec, xmid + scal ~ 1),
  
  
  #Create a range of doses:
  predDataGroups <-expand.grid(stimLevelVec = seq(min(dataToFit$stimLevelVec), max(dataToFit$stimLevelVec), length.out = 100),blockVec = unique(dataToFit$blockVec))
  #Create a new data frame for ggplot using predict and your range of new 
  #doses:
  predDataGroups$PPvec=predict(fit.nlme1,newdata=predDataGroups)
  
  p4 <- ggplot(dataToFit, aes(x=stimLevelVec, y=PPvec,colour=stimLevelVec)) + 
    geom_jitter(width=35) +
    facet_wrap(~blockVec, labeller = as_labeller(blockNames))+
    labs(x = expression(paste("Stimulation current ",mu,"A")),y=expression(paste("Peak to Peak magnitude ",mu,"V"), fill="stimulus level"),title = paste0("Subject ", subjectNum, " ID ", sid," DBS Paired Pulse EP Measurements")) + 
    guides(colour=guide_legend("stimulation level"))+ 
    geom_line(data=predDataGroups,aes(x=stimLevelVec,y=PPvec),size=2,colour='black')
  
  print(p4)
  
  if (savePlot && !avgMeas) {
    ggsave(paste0("subj_", subjectNum, "_ID_", sid,"_scatter_diffModel.png"), units="in", width=figWidth, height=figHeight, dpi=600)
  } 
  else if (savePlot && avgMeas) {
    ggsave(paste0("subj_", subjectNum, "_ID_", sid,"_scatter_diffModel_avg.png"), units="in", width=figWidth, height=figHeight, dpi=600)
  }
  
  # xtra ss test
  #   anova(fit.nlme0, fit.nlme1)  
  # Likelihood ratio test
  
  #  lrtest(fit.nlme0, fit.nlme1,fit.glm,fit.lmm)  
  
  # aic
  # AIC(fit.nlme0, fit.nlme1,fit.glm,fit.lmm)  
  
  #BIC(fit.nlme0, fit.nlme1,fit.glm,fit.lmm)
  
}


#http://rstudio-pubs-static.s3.amazonaws.com/28730_850cac53898b45da8050f7f622d48927.html