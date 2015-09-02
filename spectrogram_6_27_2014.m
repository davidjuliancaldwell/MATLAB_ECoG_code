
%%


[Cm, f, t] = spectrogram(sig_estimate_notch(:,58), 1200, 150, 1:200, 1200, 'yaxis');
Cmn = bsxfun(@rdivide, abs(Cm), mean(abs(Cm),2));
time = (1:length(sta.StimulusCode))/1200;
for c = 1:length(t)
res(c) = find(t(c)<=time,1,'first');
end
imagesc(t,f,Cmn); axis xy
colorbar
set(gca,'clim',[0 4])
set(gca,'clim',[0 3.5])
hold on; plot(t, 20+50*(sta.StimulusCode(res)~=0), 'r','linew',2);

%%
[Cm, f, t] = spectrogram(sig_estimate_notch(:,58), 1200, 150, 1:200, 1200, 'yaxis');

plot(mean(abs(Cm),2))


%%
pwelch(sig_estimate_notch(:,58), 1200, 150, 1200, 1200);
mfft(sig_estimate_notch(:,58),1,1200);

%% 6_30_2014 - task of looking at average stimulus spectrogram
% look at 1s before and after each stimulus presentation, average the
% signals, using the unfiltered signal. (sig_estimate from words file) 

% using channel of interest
sig_58 = sig_estimate(:,58);

% create matrix of data indices we want
desiredtime = 1200;
start = ind - desiredtime;
stop = ind + desiredtime;
sig_points = zeros(desiredtime*2,length(ind));

% create matrix of desired samples in rows for each stimulus presentation.
% Therefore here there are 40 channels, with 2 seconds of data centered
% around each stimulus presentation. Each channel is represented in a
% column, with the rows of that column representing each data point

for i = 1:length(ind)
    sig_points(:,i) = sig_58([start(i):stop(i)-1]);
end

% average across the rows to obtain the average signal at each time point
sig_points_avg = mean(sig_points,2);

%% visualization
% visualize 
figure
[Cm_58, f_58, t_58] = spectrogram(sig_points_avg, 80, 40, 1:200, 1200, 'yaxis');
Cmn_58 = bsxfun(@rdivide, abs(Cm_58), mean(abs(Cm_58),2));
imagesc(t_58,f_58,Cmn_58); axis xy
colorbar
set(gca,'clim',[0 4])
set(gca,'clim',[0 3.5])
