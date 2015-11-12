%% 11-3-2015
% Extract data from beta triggered stimulation files that may be of
% interest for Larry use existing stim tables, select test pulses after
% conditioning train, for falling and rising  Extract 250 ms before, 500 ms
% after, save results in META_DIR so that plots can be recreated, no
% preprocessing

%% Constants
Z_ConstantsLarryStim;
addpath ./experiment/BetaTriggeredStim/scripts/ %DJC edit 8/14/2015

%%
sid = input('enter subject ID ','s');

chans = [1:64]; % want to look at all channels, DJC 8-28-2015

%9ab7ab
switch(sid)
    case '9ab7ab'
        tp = 'C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim';
        block = 'BetaPhase-3';
        stimChans = [59 60];
        chans = [1:64]; % want to look at all channels, DJC 8-28-2015
        
        % chans = [51 52 53 58 57]; % DJC 8-31-2015, look at channels that were deemed potentially interesting before by Miah/Jared to see if I can see anything
        % chans(ismember(chans, stims)) = []; want to look at stim channels too!
        %%
        %'ecb43e'
    case 'ecb43e'
        tp = 'C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\ecb43e\data\d7\BetaStim';
        block = 'BetaPhase-3';
        stimChans = [56 64];
        chans = [1:64];
        %         chans = [47 55]; want to look at all channels
    case '8adc5c'
        % sid = SIDS{1};
        tp = 'C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\8adc5c\data\D6\8adc5c_BetaTriggeredStim';
        block = 'Block-67';
        stims = [31 32];
        %         chans = [8 7 48];
    case 'd5cd55'
        % sid = SIDS{2};
        tp = 'C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\d5cd55\data\D8\d5cd55_BetaTriggeredStim';
        block = 'Block-49';
        stims = [54 62];
        %         chans = [53 61 63];
    case 'c91479'
        % sid = SIDS{3};
        tp = 'C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\c91479\data\d7\c91479_BetaTriggeredStim';
        block = 'BetaPhase-14';
        stims = [55 56];
        %         chans = [64 63 48];
    case '7dbdec'
        % sid = SIDS{4};
        tp = 'C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\7dbdec\data\d7\7dbdec_BetaTriggeredStim';
        block = 'BetaPhase-17';
        stims = [11 12];
        %         chans = [4 5 14];
    case '702d24'
        tp = 'C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\702d24\data\d7\702d24_BetaStim';
        block = 'BetaPhase-4';
        stims = [13 14];
        %         chans = [4 5 21];
        
end
%% load in the trigger data
load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts', 'fs', 'stims');
% drop any stims that happen in the first 500 milliseconds
stims(:,stims(2,:) < fs/2) = [];


% drop any probe stimuli without a corresponding pre-burst/post-burst
% still want to do this for selecting conditioning - DJC, as this in the
% next step ensures we only select conditioning up to last one before beta
% stim train
bads = stims(3,:) == 0 & (isnan(stims(4,:)) | isnan(stims(6,:)));
stims(:, bads) = [];

tank = TTank;
tank.openTank(tp);
tank.selectBlock(block);

%% Trying to process ecog
%% process each ecog channel individually

muCell = cell(1,length(chans));
stdErrCell = cell(1,length(chans));
kwinsTotal = cell(1,length(chans));

figure

for chan = chans
    %% load in ecog data for that channel
    fprintf('loading in ecog data:\n');
    tic;
    grp = floor((chan-1)/16);
    ev = sprintf('ECO%d', grp+1);
    achan = chan - grp*16;
    
    %         [eco, efs] = tdt_loadStream(tp, block, ev, achan);
    [eco, info] = tank.readWaveEvent(ev, achan);
    efs = info.SamplingRateHz;
    eco = eco';
    
    fac = fs/efs;
    
    toc;
    
    %     eco = toRow(bandpass(eco, 1, 40, efs, 4, 'causal'));
    %     eco = toRow(notch(eco, 60, efs, 2, 'causal'));
    %
    %% Process Triggers 9-3-2015
    
    pts = stims(3,:)==0;
    ptis = round(stims(2,pts)/fac);
    
    
    % change presamps and post samps to be what Kurt wanted to look at
    presamps = round(0.25 * efs); % pre time in sec
    postsamps = round(0.5 * efs); % post time in sec
    
    t = (-presamps:postsamps)/efs;
    wins = squeeze(getEpochSignal(eco', ptis-presamps, ptis+postsamps+1));
    
    % normalize the windows to each other, using pre data
    awins = wins-repmat(mean(wins(t<0,:),1), [size(wins, 1), 1]);
    
    pstims = stims(:,pts);
    types = unique(bursts(5,pstims(4,:)));
    
    for typei = 1:length(types)
        figure
        if (types(typei) ~= nullType)
            %     % if (all)
            %     probes = pstims(5,:) < .250*fs;
            %     % if (falling)
            probes = pstims(5,:) < .250*fs & bursts(5,pstims(4,:))==types(typei);
            
            keeper = probes;
            kwins = awins(:,keeper);
            kwinsTotal{typei,chan} = kwins;
            
            mu = mean(kwins,2);
            stdErr = (std(kwins,0,2)/sqrt(size(kwins,2)));
            
            muCell{typei,chan} = mu;
            stdErrCell{chan} = stdErr;
            
            %% plot dat
            
            subplot(8,8,chan)
            
            plot(1e3*t, 1e6*mu);
            xlim(1e3*[min(t) max(t)]);
            %     yl = ylim;
            %     yl(1) = min(-10, max(yl(1),-120));
            %     yl(2) = max(10, min(yl(2),100));
            %     ylim(yl);
            hold on
            vline(0);
            
            hold on
            plot(1e3*t, 1e6*(mu+stdErr))
            hold on
            
            plot(1e3*t, 1e6*(mu-stdErr))
            
            %     xlabel('time (ms)');
            %     ylabel('ECoG (uV)');
            title(sprintf('Chan %d', chan))
            
            
        end
        
        %% put subtitle on graph, units
        
        hold on
        xlabel('time (ms)');
        ylabel('ECoG (uV)');
        
        subtitle('ecb43e Baseline Cortico-Cortical Evoked Potentials - Band passed and notched ')
        
    end
    
    %% do a plot of all channels
    
    figure
    
    for i = chans
        mu = muCell{i};
        stdErr = stdErrCell{i};
        chan = i;
        subplot(8,8,i)
        
        plot(1e3*t, 1e6*mu);
        
        xlim(1e3*[min(t) max(t)]);
        %     yl = ylim;
        %     yl(1) = min(-10, max(yl(1),-120));
        %     yl(2) = max(10, min(yl(2),100));
        %     ylim(yl);
        hold on
        %     vline(0);
        %
        %     hold on
        %     plot(1e3*t, 1e6*(mu+stdErr))
        %     hold on
        %
        %     plot(1e3*t, 1e6*(mu-stdErr))
        title(sprintf('Chan %d', chan))
        %
        %     xlabel('time (ms)');
        %     ylabel('ECoG (uV)');
        %
        %     title(sprintf('CCEP, Channel %d', chan))
        
        
        
    end
end


end



%% plot channel of interest

chanInt = input('whats your channel of interest? ');
mu = muCell{chanInt};

figure

plot(1e3*t,1e6*mu)

%%
save(fullfile(META_DIR, [sid '_LarryStatsRAWPlastic.mat']), 't', 'kwinsTotal', 'muCell','stdErrCell','-v7.3');

%% plot cortex

switch(sid)
    case '9ab7ab'
        load('C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\9ab7ab\data\d4\9ab7ab_baseline8001\9ab7ab_baseline8S001R01_montage.mat')
        
        locs = trodeLocsFromMontage(sid, Montage, false);
        
        % use significant channels
        zVec = cell2mat(zCell);
        zVec(zVec < 6) = NaN;
        
        % now plot the weights on the subject specific brain. PlotDotsDirect has a
        % bunch of input arguments
        figure;
        
        clims = [6 40];
        PlotDotsDirect(sid, ... % the subject on who's brain the electrodes will be drawn
            locs, ... % the location of the electrodes
            zVec, ... % the weights to use for coloring
            'l', ... % the hemisphere of the brain to draw (can be 'l', 'r', or 'b')
            clims, ... % the color limits for the weights
            15, ... % the size of the dots, in points I believe
            'recon_colormap', ... % the colormap to use for dot coloration
            1:64, ... % labels for the electrodes, I think this can be a cell array
            true, ... % a boolean switch as to whether or not to draw the labels
            false); % a boolean switch as to whether or not to redraw the cortex, used for multiple
        % calls to PlotDotsDirect where you don't want to keep
        % re-drawing the brain over itself
        
        % very often, after plotting the brain and dots, I add a colorbar for
        % reference as to what the dot colors mean
        load('recon_colormap'); % needs to be the same as what was used in the function call above
        colormap(cm);
        colorbar;
        
    case 'ecb43e'
        
        %there appears to be no montage for this subject currently
        Montage.Montage = 64;
        Montage.MontageTokenized = {'Grid(1:64)'};
        Montage.MontageString = Montage.MontageTokenized{:};
        Montage.MontageTrodes = zeros(size(eco,2), 3);
        Montage.BadChannels = [];
        Montage.Default = true;
        
        % get electrode locations
        locs = trodeLocsFromMontage(sid, Montage, false);
        
        % use significant channels
        zVec = cell2mat(zCell);
        zVec(zVec < 6) = NaN;
        
        % now plot the weights on the subject specific brain. PlotDotsDirect has a
        % bunch of input arguments
        figure;
        
        clims = [6 40];
        PlotDotsDirect(sid, ... % the subject on who's brain the electrodes will be drawn
            locs, ... % the location of the electrodes
            zVec, ... % the weights to use for coloring
            'l', ... % the hemisphere of the brain to draw (can be 'l', 'r', or 'b')
            clims, ... % the color limits for the weights
            10, ... % the size of the dots, in points I believe
            'recon_colormap', ... % the colormap to use for dot coloration
            1:64, ... % labels for the electrodes, I think this can be a cell array
            true, ... % a boolean switch as to whether or not to draw the labels
            false); % a boolean switch as to whether or not to redraw the cortex, used for multiple
        % calls to PlotDotsDirect where you don't want to keep
        % re-drawing the brain over itself
        
        % very often, after plotting the brain and dots, I add a colorbar for
        % reference as to what the dot colors mean
        load('recon_colormap'); % needs to be the same as what was used in the function call above
        colormap(cm);
        colorbar;
        
        
end