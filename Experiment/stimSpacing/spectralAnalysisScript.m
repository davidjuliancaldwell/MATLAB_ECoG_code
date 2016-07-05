%% 7/4/2016 - spectral analysis script DJC

%close all;

% example channel for stim_28_29 
idx = 21;

dataNoStim = dataEpochedHigh(t>5,:,:);
dataStacked = dataNoStim(:,idx,:);
%dataStacked = notch(dataStacked(:),[60 120 180 240],fs_data);
dataStacked = dataStacked(:);
figure
plot(dataStacked);

%[u,s,v] = svd(dataStacked);


data_permuted  = permute(dataNoStim,[1,3,2]);
data_stacked = reshape(data_permuted,[size(data_permuted,1)*size(data_permuted,2),size(data_permuted,3)]);
figure
plot(data_stacked(:,21))
goods = ones(72,1);
bads = [28,29,72:80];
goods(bads) = 0;
goods = logical(goods);
dataStackedGood = data_stacked(:,goods);
notch_stacked = input('notch the data? "yes" or "no"','s');
if strcmp(notch_stacked,'yes')
    dataStackedGood = notch(dataStackedGood,[60 120 180 240],fs_data);
end
%[u,s,v] = svd(dataStackedGood);

%%
[u,s,v] = svd(dataStackedGood','econ');

figure
plot(diag(s),'ko','Linewidth',[2])
% to get percentage in mode
subplot(2,1,1) % plot normal
plot(diag(s)/sum(diag(s)),'ko','Linewidth',[2])
title('singular values, fractions')
set(gca,'fontsize',14)

subplot(2,1,2) % plot semilog
semilogy(diag(s)/sum(diag(s)),'ko','Linewidth',[2])
title('singular values, fractions, semilog plot')
set(gca,'fontsize',14)

% look at the modes
figure
x = [1:size(dataStackedGood,2)];
plot(x,u(:,1:3),'Linewidth',[2])
title('mode spatial locations'), legend('show')
legend({'mode 1','mode 2','mode 3'});


% look at temporal part - columns of v
figure

plot(v(:,1:3),'Linewidth',[2])
title('Temporal portion of the 3 modes'), legend('show')
legend({'mode 1','mode 2','mode 3'});


%% dmd

Xraw = dataStackedGood';
dt = 1/fs_data;

% added in dt optional argument, dt is our sampling frequency
% added in number of stacks. Using 5 for right now. The paper talks about
% hn > 2m, where h is the stack number, n is the number of channels, and m
% is time snapshots

% r sets rank truncation
[Phi, mu, lambda, diagS, x0] = DMD(Xraw,'dt',dt,'nstacks',5);

% look at modes from SVD augmented data matrix
% look at diagonal of matrix S - singular values

figure
plot(diagS(1:min(size(Xraw))),'ko','Linewidth',[2])

% to get percentage in mode
subplot(2,1,1) % plot normal
plot(diagS(1:min(size(Xraw)))/sum(diagS(1:min(size(Xraw)))),'ko','Linewidth',[2])
title('singular values, fractions')
set(gca,'fontsize',14)

subplot(2,1,2) % plot semilog
semilogy(diagS(1:min(size(Xraw)))/sum(diagS(1:min(size(Xraw)))),'ko','Linewidth',[2])
title('singular values, fractions, semilog plot')
set(gca,'fontsize',14)
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

