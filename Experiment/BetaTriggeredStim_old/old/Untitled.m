figure; hold on;
plot(ecog_ts,smon(4,1:2:end))
plot(ecog_ts,tdat(4,1:2:end),'r')
plot(ecog_ts,zscore(ecog(1,:)),'g')