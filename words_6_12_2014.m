%% load in data, plot it 
[sig, sta, par] = load_bcidatUI(pwd);
PlotStates(sta,par);

%d5 9d10c8- pic, nouns, 
% start with 9d10c8/data/d5/9d10c8_pics001/9d10c8_picsS001R02.dat 
%find out information about data, need frequency? 
par.SamplingRate;
freq = 1200;

%% preprocessing steps
%  . first calculate INITIATION of each trial. Transition using diff from
%  0 to some #, does not matter for this task what the # is (use
%  sta.StimulusCode), so x>0 is what we want. USE DOUBLES NOT UNSIGNED INTS
%  Assume later that ind shows start of signal, assume 500 ms response
%  time, and then average signal for about a second. compute COMPLETION of
%  each trial to figure out when to allow for 500 ms recovery 

x = diff(double(sta.StimulusCode));
ind = find(x > 0); %ind stores indices of transition points, initiation
ind_neg = find(x < 0); %ind_neg stores completion of target signal 

%  compute length of StimulusCode presentation, (ind_neg(1)-ind(1))/(freq),
%  3 seconds? still only use 1? 

%convert signal from single to double
sig = double(sig);

%  . common average re-reference find estimate of Vref using sum of signals
%  divided by N, then subtract this from every signal to obtain estimate of
%  Voltage. 64 channels, so N is 64. Start by doing sum across each
%  row(each time point) to find an Vref at each timepoint, then subtract
%  this from every time point. Assuming Vref may change slightly at
%  different time points? Other option is to average all Vrefs and subtract
%  the same number for uniformity? 
% 

v_est_ref = (1/64)*sum(sig,2);
sig_estimate = bsxfun(@minus,sig,v_est_ref);

%  . denoising
%  .   removal of artifactual trials (not doing this right now)

%  .   notch filtering for line noise, center it around 60 hz, 

sig_estimate_notch = notch(sig_estimate, [60], 1200); 

%  .   bandpass filter (butterworth IIR), start with Miah's function, and
%  then move to writing own for interest 

sig_estimate_notch_bandpass = bandpass(sig_estimate_notch,70,200,1200);


%% extract the random variable(s) of interest
%  . perform spectral estimation - hilbert transform 

sig_hilbert = log((abs(hilbert(sig_estimate_notch_bandpass)).^2));

%  . average across time

%  . delay1 represents the time from onset of target stimulus, 0.5 s * 1200
%  Hz = 600 samples, then average for 1 second * 1200 hz = 1200 samples.
%  delay2 represents the time waiting for recovery, assume 500 ms recovery
%  time, so delay 1 still holds. after completion, take 1 s of data to
%  figure out 

delay1 = 600;
avgtime = 1200;

%stim_data = sig_hilbert(ind+delay1:ind+avgtime, :)

% figuring out way to subselect repeated interval in StimulusCode so can
% use it to get the random non task data and task data, enter desired
% repitions (how many samples to get for each index). subset = indices of
% desired time periods for time vector. Each time the loop runs, a column
% is added below the initial indices that has the next time point. In this
% way, each column represents the desired starting index plus however many
% samples want to be added 
% 
desired_rep = 1200;

ind_task = ind + delay1;
ind_random = ind_neg + delay1;

%using getEpochMeans

sig_task = getEpochMeans(sig_hilbert, ind_task, ind_task+desired_rep);
sig_random = getEpochMeans(sig_hilbert, ind_random, ind_random+desired_rep);

%trying to do the above with for loops, replaced by above on 6/16/2014 
%{
subset_task = ind_task; 
for i = 1:desired_rep
    subset_task = [subset_task;ind_task+i];
end

subset_task = subset_task(:); % this collapses it

subset_random = ind_random;
for i = 1:desired_rep
    subset_random = [subset_random;ind_random+i];
end

subset_random = subset_random(:);

sig_task = sig_hilbert(subset_task,:);
sig_random = sig_hilbert(subset_random,:);
%}
%% perform statistical analyses
%  . ttest2?
sig_task_trans = sig_task';
sig_random_trans = sig_random';

[h,p,ci,stats] = ttest2(sig_task,sig_random, 'dim', 2);

%  . corrcoef

behav = [zeros(40, 1); ones(40, 1)];

r = zeros(64,1);
% p = zeros(64,1);
for i = 1:length(sig_task')
    r(i) = corr(behav, [sig_task_trans(:,i);sig_random_trans(:,i)]);
%     [temp_r,temp_p] = corrcoef([sig_task_trans(:,i) sig_random_trans(:,i)]);
%     r(i) = temp_r(1,2); 
%     p(i) = temp_p(1,2);
end
 
figure
scatter(stats.tstat, r); %compare stats.tstat and correlation coefficient 

%% visualize
figure
plot(stats.tstat)
line([1 64], [2.96 2.96])
[~,sigT] = findpeaks(stats.tstat,'MinPeakheight',2.96);
hold on
plot(sigT,stats.tstat(sigT),'rv','markerfacecolor','r');

figure
plot(r.^2)

figure
hold on
i = 58;
x0 = zeros(40,1);
x1 = ones(40,1);
scatter(x0,sig_task_trans(:,i))
scatter(x1,sig_random_trans(:,1))

