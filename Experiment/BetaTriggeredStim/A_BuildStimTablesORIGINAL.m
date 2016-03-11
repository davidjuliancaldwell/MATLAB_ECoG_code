%% Constants
Z_Constants;
addpath ./scripts/ %DJC edit 7/17/2015

%% Load in the trigger data

sid = SIDS{2};

if (strcmp(sid, '8adc5c'))
    tp = 'D:\Subjects\8adc5c\data\D6\8adc5c_BetaTriggeredStim';
    block = 'Block-67';

    % SMon-2 is the stim command
    % SMon-4 is the realized voltage
    tic;
    [smon, fs] = tdt_loadStream(tp, block, 'SMon', 2);
    [stim, ~] = tdt_loadStream(tp, block, 'SMon', 4);
    toc;

    % Wave-1 looks like the trigger signal
    % Wave-2 is the mode
    % Wave-3 is the mode time/counter
    % Wave-4 looks like the stim command
    tic;
    [mode, ~] = tdt_loadStream(tp, block, 'Wave', 2);
    [beta, ~] = tdt_loadStream(tp, block, 'Wave', 1);
    ttype = 0*beta;
    toc;

%     % these three lines will get rid of first 1000 stimuli where the
%     threshold was being changed a lot.
    mode(1:1.1e7) = 0;
    beta(1:1.1e7) = 0;
    smon(1:1.1e7) = 0;
    stim(1:1.1e7) = 0;
    ttype(1:1.1e7) = 0;
    
elseif (strcmp(sid, 'd5cd55'))
    tp = 'D:\Subjects\d5cd55\data\D8\d5cd55_BetaTriggeredStim';
    block = 'Block-49';

    % SMon-1 is the system enable
    % SMon-2 is the stim command
    % SMon-3 is the stim count
    % SMon-4 is the realized voltage
    tic;
    [smon, fs] = tdt_loadStream(tp, block, 'SMon', 2);
    [stim, ~] = tdt_loadStream(tp, block, 'SMon', 4);
    toc;

    % in the recording for d5cd55
    % Wave-1 looks like the trigger signal
    % Wave-2 is the mode
    % Wave-3 is the mode time/counter
    % Wave-4 looks like the stim command
    tic;
    [mode, ~] = tdt_loadStream(tp, block, 'Wave', 2);
    [beta, ~] = tdt_loadStream(tp, block, 'Wave', 1);
    ttype = 0*beta;
    toc;
    
    % UNCOMMENTED THESE - DJC 2-22-2016 

    % these three lines will get rid of the large simuli at the beginning
    % of the record
    mode(1:4.5e6) = [];
    beta(1:4.5e6) = [];
    smon(1:4.5e6) = [];
    
    % these three lines will get rid of all stimuli until we reset the
    % threshold value
    mode(1:36536266) = [];
    beta(1:36536266) = [];
    smon(1:36536266) = [];

%     % these lines will get rid of all stimuli after we reset the threshold
%     % value
%     mode(36536266:end) = [];
%     beta(36536266:end) = [];
%     smon(36536266:end) = [];
%     mode(1:4.5e6) = [];
%     beta(1:4.5e6) = [];
%     smon(1:4.5e6) = [];

elseif (strcmp(sid, 'c91479'))    
    tp = 'D:\Subjects\c91479\data\d7\c91479_BetaTriggeredStim';
    block = 'BetaPhase-14';
    
    % SMon-1 is the system enable
    % SMon-2 is the stim command
    % SMon-3 is the stim count
    % SMon-4 is the realized voltage
    tic;
    [smon, fs] = tdt_loadStream(tp, block, 'SMon', 2);
    [stim, ~] = tdt_loadStream(tp, block, 'SMon', 4);
    toc;
    
    % in the recording for c91479
    % Wave-1 looks like phase decision variable (0=falling, 1=rising)
    % Wave-2 is the mode
    % Wave-3 is the mode time/counter
    % Wave-4 looks like the stim command
    tic;
    [mode, ~] = tdt_loadStream(tp, block, 'Wave', 2);
    [ttype, ~] = tdt_loadStream(tp, block, 'Wave', 1);
    [beta, ~] = tdt_loadStream(tp, block, 'Blck', 1);
    [raw, ~] = tdt_loadStream(tp, block, 'Blck', 2);
    toc;
    
    % these lines will get rid of the time period at the end of the record
    % where we were trying a lower max stim frequency
    mode(64507402:end) = 0;
    ttype(64507402:end) = 0;
    beta(64507402:end) = 0;
    smon(64507402:end) = 0;
    stim(64507402:end) = 0;    
    raw(64507402:end) = 0;    
    
    % these lines will get rid of the time period at the beginning of
    % the record where we were changing parameter settings
    mode(1:2e7) = 0;
    ttype(1:2e7) = 0;
    beta(1:2e7) = 0;
    smon(1:2e7) = 0;
    stim(1:2e7) = 0;    
    raw(1:2e7) = 0;    
elseif (strcmp(sid, '7dbdec'))    
    tp = 'D:\Subjects\7dbdec\data\d7\7dbdec_BetaTriggeredStim';
    block = 'BetaPhase-17';
    
    % SMon-1 is the system enable
    % SMon-2 is the stim command
    % SMon-3 is the stim count
    % SMon-4 is the realized voltage
    tic;
    [smon, fs] = tdt_loadStream(tp, block, 'SMon', 2);
    [stim, ~] = tdt_loadStream(tp, block, 'SMon', 4);
    toc;
    
    % Wave-1 looks like phase decision variable (0=falling, 1=rising)
    % Wave-2 is the mode
    % Wave-3 is the mode time/counter
    % Wave-4 looks like the stim command
    tic;
    [mode, ~] = tdt_loadStream(tp, block, 'Wave', 2);
    [ttype, ~] = tdt_loadStream(tp, block, 'Wave', 1);
    [beta, ~] = tdt_loadStream(tp, block, 'Blck', 1);
    [raw, ~] = tdt_loadStream(tp, block, 'Blck', 2);
    toc;    
elseif (strcmp(sid, '9ab7ab'))    
    tp = 'D:\Subjects\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim';
    block = 'BetaPhase-3';
    
    % SMon-1 is the system enable
    % SMon-2 is the stim command
    % SMon-3 is the stim count
    % SMon-4 is the realized voltage
    tic;
    [smon, fs] = tdt_loadStream(tp, block, 'SMon', 2);
    [stim, ~] = tdt_loadStream(tp, block, 'SMon', 4);
    toc;
    
    % Wave-1 looks like the beta signal (SHIT!), should have been the 
      % decision variable
      
    % Wave-2 is the mode
    % Wave-3 is the mode time/counter
    % Wave-4 looks like the stim command
    tic;
    [mode, ~] = tdt_loadStream(tp, block, 'Wave', 2);
%     [ttype, ~] = tdt_loadStream(tp, block, 'Wave', 1);

    [x1, ~] = tdt_loadStream(tp, block, 'Wave', 3);
    [x2, ~] = tdt_loadStream(tp, block, 'Wave', 4);
    
    ttype = 0*mode;
    [beta, ~] = tdt_loadStream(tp, block, 'Blck', 1);
    [raw, ~] = tdt_loadStream(tp, block, 'Blck', 2);
    toc;    
elseif (strcmp(sid, '702d24'))    
    tank = TTank;
    tank.openTank('D:\Subjects\702d24\data\d7\702d24_BetaStim');
    tank.selectBlock('BetaPhase-4');
%     tp = 'd:\research\subjects\702d24\data\d7\702d24_BetaStim';
%     block = 'BetaPhase-4';
    
    % SMon-1 is the system enable
    % SMon-2 is the stim command
    % SMon-3 is the stim count
    % SMon-4 is the realized voltage
    tic;
    [smon, info] = tank.readWaveEvent('SMon', 2);
    smon = smon';
    
    fs = info.SamplingRateHz;
    
    stim = tank.readWaveEvent('SMon', 4)';
    toc;
    
    % Wave-1 looks like the beta signal (SHIT!), should have been the 
      % decision variable
      
    % Wave-2 is the mode
    % Wave-3 is the mode time/counter
    % Wave-4 looks like the stim command
    tic;
    mode = tank.readWaveEvent('Wave', 2)';
    ttype = tank.readWaveEvent('Wave', 1)';

    beta = tank.readWaveEvent('Blck', 1)';
%     [beta, ~] = tdt_loadStream(tp, block, 'Blck', 1);
    raw = tank.readWaveEvent('Blck', 2)';
%     [raw, ~] = tdt_loadStream(tp, block, 'Blck', 2);
    toc;    
else
    error('unknown sid entered');
end

%% build a burst table with the following
% 1 - burst id
% 2 - burst start sample
% 3 - burst stop sample
% 4 - nstims in burst (do last)
% 5 - type of conditioning (0 = falling, 1 = rising)

bursts = [];

dmode = diff([0 mode 0]);
dmode(end-1) = dmode(end);
dmode(end) = [];

bursts(2,:) = find(dmode==1);
bursts(3,:) = find(dmode==-1);

if (exist('ttype', 'var'))    
    bursts(5,:) = ttype(bursts(2,:));
else
    bursts(5,:) = 0;
end

% discard the bursts that don't have any stimuli
keeper = false(1, size(bursts, 2));
for bursti = 1:size(bursts, 2)
    r = bursts(2,bursti):bursts(3,bursti);    
    keeper(bursti) = sum(smon(1, r)) > 0;
end

bursts(:, ~keeper) = [];

bursts(1,:) = 1:size(bursts,2);

%% build a table with the following
% 1 - stim id
% 2 - sample number where occurred
% 3 - mode
% 4 - burst before
% 5 - n samples after previous burst
% 6 - burst after
% 7 - n samples before previous burst
% 8 - stim type (rising or falling edge of beta)

stims = [];

stims(2,:) = find(smon(1,:)==1);
stims(1,:) = 1:size(stims,2);
stims(3,:) = mode(1,stims(2,:));

for stimi = 1:size(stims,2)
    if (stims(3,stimi)==1) % in burst
        stims(4:7, stimi) = NaN;
        stims(8, stimi) = ttype(stims(2,stimi));
    else
        prebursti = find(stims(2,stimi) - bursts(3,:) > 0, 1, 'last');
        if (isempty(prebursti))
            stims(4:5, stimi) = NaN;
        else
            stims(4, stimi) = prebursti;
            stims(5, stimi) = stims(2,stimi)-bursts(3,prebursti);
        end
                
        postbursti = find(bursts(2,:) - stims(2, stimi) > 0, 1, 'first');
        if (isempty(postbursti))
            stims(6:7) = NaN;
        else
            stims(6, stimi) = postbursti;
            stims(7, stimi) = bursts(2, postbursti) - stims(2, stimi);
        end                
        
        stims(8, stimi) = NaN;
    end    
end

%% go back to the bursts array and figure out how many ct's for each burst

for bursti = 1:size(bursts, 2)
    bursts(4,bursti) = sum(stims(2,:) > bursts(2,bursti) & stims(2,:) < bursts(3, bursti));
end

%% save the result to intermediate file for future use
% added mod
save(fullfile(META_DIR, [sid '_tables_modDJC_2_22_2016V2.mat']), 'bursts', 'fs', 'stims');

%% testing
%
% % visualize the triggers (this is slow)
% figure
% plot(smon)
% hold all;
% plot(mode, 'linew', 2)
%
% pts = stims(3,:)==0;
% cts = stims(3,:)==1;
%
% plot(stims(2,pts), ones(sum(pts),1),'.');
% plot(stims(2,cts), ones(sum(cts),1),'.');
%
% % visualize the distribution of stims per burst
% figure
% error('needs to be reworked for multiple conditioning types');
% hist(bursts(4,:),100)
%
% visualize the average trigger signal
figure

if strcmp(sid,'d5cd55')
    sid = 'd5cd55modBurstV2';
end 
% modified by DJC 2-21-2016 to set figure to be the full size of the window
% 
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);

% origianl was pre samp 0.020, postSamp 0.100, change to try and look at
% curve fitting 
preSamp = round(0.050 * fs);
postSamp = round(0.050 * fs);

utype = unique(ttype); %ttype is the trigger type, reports different unique types

cts = stims(3,:)==1; % Stims that are conditioning stimuli

dat = squeeze(getEpochSignal(beta', stims(2, cts)-preSamp, stims(2, cts)+postSamp+1)); %getting segments of beta signals
% rdat = squeeze(getEpochSignal(raw', stims(2, cts)-preSamp, stims(2, cts)+postSamp+1)); %getting segments of raw ECoG signals

% first eliminate those where storage was incorrect:
% bads = sum(rdat==0,1)>10;

% dat(:, bads) = [];
% rdat(:,bads) = [];

% bdat = rdat - repmat(mean(rdat(1:100,:)), size(rdat, 1), 1);

t = (-preSamp:postSamp) / fs;

stimtypes = stims(8, cts);

for idx = 1:length(utype)
    mtype = utype(idx);
    subplot(length(utype),2,2*(idx-1)+1);
    
    mdat = squeeze(dat(:, stimtypes==mtype));
    badmoment = diff(mdat,1,1)==0;
    badmoment = cat(1, false(1, size(badmoment, 2)), badmoment);
    mdat(badmoment) = NaN;
    %     bads = mean(diff(mdat,1,1)==0) > 0.05;
    plot(1e3*t, 1e6*mdat(:,1:10:end)','color', [0.5 0.5 0.5]);
    hold on;

    
    plot(1e3*t, 1e6*nanmean(squeeze(mdat),2), 'r', 'linew', 2);
    xlabel('Time (msec)');
    ylabel('Trigger signal (uV)');
    title(sprintf('average \\beta trigger; cond type = %d', mtype));
    xlim([min(1e3*t) max(1e3*t)]);
    
    %     ylim([-120 120]);
    vline(0, 'k:');
    %%
        
    % DJC 2-22-2016, look at how to find phase angle and get distribution
    % of phases
    
    % get from beginning to 10 ms after stim from beta channel
    mdatTrim = mdat(((1e3*t)<10),:);
    
%     betaAngle = angle(mdatTrim);
%     
%     % from mathworks - instananeous phase? 
%     x = hilbert(mdatTrim);
%     
%     for k = 1:length(x)-1
%      phi(k) = angle(x
% %This is a parametric modeling that exactly represents the signal.
% %Fit a polynomial curve to the phase:
%   p = polyfit(0:N-1,unwrap(phi),your_favorite_order);
% %Differentiate:
%   dp = p(1:end-1).*(your_favorite_order-1:1);
% %Evaluate:
%   f = polyval(dp, 0:N-1)/2/pi;
%     end
%     
    
   %% 
%     
%     subplot(length(utype),2,2*(idx-1)+2);
%     mrdat = squeeze(rdat(:, stimtypes==mtype));
%     plot(1e3*t, 1e6*mrdat(:,1:10:end)','color', [0.5 0.5 0.5]);
%     hold on;
%     
%     plot(1e3*t, 1e6*mean(squeeze(mrdat),2), 'r', 'linew', 2);
%     xlabel('Time (msec)');
%     ylabel('Trigger signal (uV)');
%     title(sprintf('average raw response; cond type = %d', mtype));
%     xlim([min(1e3*t) max(1e3*t)]);
%     ylim([-120 120]);
%     vline(0, 'k:');
%     
    
end

% SaveFig(OUTPUT_DIR, sprintf('trigger-%s', sid), 'eps', '-r600'); % changed OUTPUT_DIR to allow figure to save
% SaveFig(OUTPUT_DIR, sprintf('trigger-%s', sid), 'png', '-r600');

% %%
% figure
% for c = 1:1000
%     plot(t, dat(:,1, c));
%     pause
% end
%
%
% %%
% res = [];
%
% for e = 1:4431
% %     res(e) = any(find(diff(dat(:,1,e)) > 1e-6));
%     res(e) = rdat(find(t>0,1,'first'),1,e)==0;
%
% end
% %%
% figure
% for c = find(res)
%     plot(t, rdat(:,1,c));
%     pause
% end

%% TEMP
figure
hist = find(mode ~= 0 & smon ~= 0);
X = getEpochSignal(beta', hist-round(fs*0.1), hist+round(fs*.1));
t= round(-fs*.1):round(fs*.1);
t(end) = [];
plot(t/fs, squeeze(X))
vline(0)
vline(-390/fs, 'k:')
hold all
plot(t/fs, mean(squeeze(X)'), 'k', 'linew', 3);