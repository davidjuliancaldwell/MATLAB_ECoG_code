%% 7/4/2016 - spectral analysis script DJC

%close all;
idx = 21;

dataNoStim = dataEpochedHigh(t>5,:,:);
dataStacked = dataNoStim(:,idx,:);
%dataStacked = notch(dataStacked(:),[60 120 180 240],fs_data);
dataStacked = dataStacked(:);
figure
plot(dataStacked);

[u,s,v] = svd(dataStacked);

%%

filter_it = input('notch filter? input "yes" or "no"','s');

sig = mean(dataEpochedLow(:,idx,:),3);
t_pre = t(t<0);
t_post = t(t>5);

if strcmp(filter_it,'yes')
sig_pre = notch(sig(t<0),[60 120 180 240],fs_data);
sig_post = notch(sig(t>5),[60 120 180 240],fs_data);
else
    sig_pre = sig(t<0);
    sig_post = sig(t>5);

end
    

figure

[f_pre,P1_pre] = spectralAnalysis(fs_data,t_pre,sig_pre); 

[f_post,P1_post] = spectralAnalysis(fs_data,t_post,sig_post);


sig = mean(dataEpochedMid(:,idx,:),3);

if strcmp(filter_it,'yes')
sig_post = notch(sig(t>5),[60 120 180 240],fs_data);
else
    sig_post = sig(t>5);

end

sig_post = sig(t>5);
sig_post = notch(sig(t>5),[60 120 180 240],fs_data);


[f_post,P1_post] = spectralAnalysis(fs_data,t_post,sig_post);

sig = mean(dataEpochedHigh(:,idx,:),3);

if strcmp(filter_it,'yes')
sig_post = notch(sig(t>5),[60 120 180 240],fs_data);
else
    sig_post = sig(t>5);

end

[f_post,P1_post] = spectralAnalysis(fs_data,t_post,sig_post);


legend({'pre','low','mid','high'})

