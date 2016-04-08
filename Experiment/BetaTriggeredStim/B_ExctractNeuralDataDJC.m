%% Constants
close all; clear all;clc
% cd 'C:\Users\David\Desktop\Research\RaoLab\MATLAB\Code\Experiment\BetaTriggeredStim'
Z_Constants;
addpath ./scripts/ %DJC edit 7/20/2015;

SUB_DIR = fullfile(myGetenv('subject_dir'));
% OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'));

%% parameters

% need to be fixed to be nonspecific to subject
% SIDS = SIDS(2:end);
SIDS = SIDS(7);

for idx = 1:length(SIDS)
    sid = SIDS{idx};
    %DJC edited 7/20/2015 to fix tp paths
    switch(sid)
        case '8adc5c'
            % sid = SIDS{1};
            tp = strcat(SUB_DIR,'\8adc5c\data\D6\8adc5c_BetaTriggeredStim');
            block = 'Block-67';
            stims = [31 32];
            chans = [8 7 48];
        case 'd5cd55'
            % sid = SIDS{2};
             tp = strcat(SUB_DIR,'\d5cd55\data\D8\d5cd55_BetaTriggeredStim');
            block = 'Block-49';
            stims = [54 62];
            chans = [53 61 63];
            chans = [1:64];
            
        case 'c91479'
            % sid = SIDS{3};
            tp = strcat(SUB_DIR,'\c91479\data\d7\c91479_BetaTriggeredStim');
            block = 'BetaPhase-14';
            stims = [55 56];
            chans = [64 63 48];
            chans = [1:64];
            
        case '7dbdec'
            % sid = SIDS{4};
            tp = strcat(SUB_DIR,'\7dbdec\data\d7\7dbdec_BetaTriggeredStim');
            block = 'BetaPhase-17';
            stims = [11 12];
            chans = [4 5 14];
            chans = [1:64];
            
        case '9ab7ab'
            %             sid = SIDS{5};
            tp = strcat(SUB_DIR,'\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim');
            block = 'BetaPhase-3';
            stims = [59 60];
            chans = [51 52 53 58 57];
            chans = [1:64];
            
            % chans = 29;
        case '702d24'
            tp = strcat(SUB_DIR,'\702d24\data\d7\702d24_BetaStim');
            block = 'BetaPhase-4';
            stims = [13 14];
            chans = [4 5 21];
            chans = [1:64];
%             chans = [36:64];

        case 'ecb43e' % added DJC 7-23-2015
            tp = strcat(SUB_DIR,'\ecb43e\data\d7\BetaStim');
            block = 'BetaPhase-3';
            stims = [56 64];
            chans = [47 55];
            chans = [1:64];
            
        case '0b5a2e' % added DJC 7-23-2015
            tp = strcat(SUB_DIR,'\0b5a2e\data\d8\0b5a2e_BetaStim\0b5a2e_BetaStim');
            block = 'BetaPhase-2';
            stims = [22 30];
            chans = [23 31];
        case '0b5a2ePlayback' % added DJC 7-23-2015
            tp = strcat(SUB_DIR,'\0b5a2e\data\d8\0b5a2e_BetaStim\0b5a2e_BetaStim');
            block = 'BetaPhase-4';
            stims = [22 30];
            chans = [23 31];
        otherwise
            error('unknown SID entered');
    end
    
    chans(ismember(chans, stims)) = [];
    
    %% load in the trigger data
    % 9-2-2015 DJC added mod DJC
    % below is for original miah style burst tables
    
    load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts', 'fs', 'stims');
    % below is for modified burst tables
    %         load(fullfile(META_DIR, [sid '_tables_modDJC.mat']), 'bursts', 'fs', 'stims');
    
    % below is for EXTRA modified burst table of d5cd55, leaving out the
    % ones that miah and jared said 2-22-2016
    
    %     load(fullfile(META_DIR, [sid '_tables_modDJC_2_22_2016.mat']), 'bursts', 'fs', 'stims');
    
    
    
    
    % drop any stims that happen in the first 500 milliseconds
    stims(:,stims(2,:) < fs/2) = [];
    
    % drop any probe stimuli without a corresponding pre-burst/post-burst
    bads = stims(3,:) == 0 & (isnan(stims(4,:)) | isnan(stims(6,:)));
    stims(:, bads) = [];
    
    tank = TTank;
    tank.openTank(tp);
    tank.selectBlock(block);
    
    figure
    
    sigChans = {};
    shuffleChans = {};
    CCEPbyNumStim = {};
    
    % 4/4/2016 - added data for anova 
    dataForAnova = {};
    
        
    % 4/7/2016 - Zscored data for anova
    ZscoredDataForAnova = {};
    
    %% process each ecog channel individually
    for chan = chans
        
        %% load in ecog data for that channel
        fprintf('loading in ecog data:\n');
        fprintf('channel %d:\n',chan);
        tic;
        grp = floor((chan-1)/16);
        ev = sprintf('ECO%d', grp+1);
        achan = chan - grp*16;
        
        %         [eco, efs] = tdt_loadStream(tp, block, ev, achan);
        [eco, info] = tank.readWaveEvent(ev, achan);
        efs = info.SamplingRateHz;
        eco = eco';
        
        toc;
        
        fac = fs/efs;
        
        % %         %% preprocess eco
        % %         presamps = round(0.025 * efs); % pre time in sec
        % %         postsamps = round(0.120 * efs); % post time in sec
        % %
        % %         sts = round(stims(2,:) / fac);
        % %         edd = zeros(size(sts));
        % %
        % %
        % %         temp = squeeze(getEpochSignal(eco', sts-presamps, sts+postsamps+1));
        % %         foo = mean(temp,2);
        % %         lastsample = round(0.040 * efs);
        % %         foo(lastsample:end) = foo(lastsample-1);
        % %
        % %         last = find(abs(zscore(foo))>1,1,'last');
        % %         last2 = find(abs(diff(foo))>30e-6,1,'last')+1;
        % %
        % % %         plot(foo);
        % % %         vline(last)
        % % %         vline(last2,'k:');
        % %
        % %         zc = false;
        % %         ct = max(last, last2);
        % %
        % %         while (~zc && ct <= length(foo))
        % %             zc = sign(foo(ct-1)) ~= sign(foo(ct));
        % %             ct = ct + 1;
        % %         end
        % %
        % % %         vline(ct-1,'g');
        % % %         hline(0);
        % %
        % %
        % %         for sti = 1:length(sts)
        % %             win = (sts(sti)-presamps):(sts(sti)+postsamps+1);
        % % %             win = sts(sti):(sts(sti)+round(efs * 0.010));
        % %
        % % %             % replacement approach
        % % %             mask = ones(size(win));
        % % %             mask(presamps:(ct-1)) = 0;
        % % %             eco(win) = eco(win) .* mask;
        % %
        % %             % interpolation approach
        % %             eco(win(presamps:(ct-1))) = interp1([presamps-1 ct], eco(win([presamps-1 ct])), presamps:(ct-1));
        % %         end
        % %
        % % % %         for sti = 1:length(sts)
        % % % % % %             % find the first zero crossing 4 msec after the stim command
        % % % % % %             last = floor(efs * 1e-3);
        % % % % % %             win = sts(sti):(sts(sti)+round(efs * 0.010));
        % % % % % %             mask = ones(size(win));
        % % % % % %
        % % % % % %             ct = last;
        % % % % % %
        % % % % % %             mask(1:ct) = 0;
        % % % % % %             eco(win) = eco(win) .* mask;
        % % % %
        % % % % %             % find the zero crossing after the stimulus
        % % % % %             win = sts(sti):(sts(sti)+round(efs * 0.020));
        % % % % %
        % % % % %             nwin = ((eco(win)-mean(eco(win(1:10))))/std(eco(win(1:10))));
        % % % % %             active = abs(nwin) > 50;
        % % % % %             last = find(active, 1, 'last');
        % % % % %
        % % % % %             if (isempty(last))
        % % % % %                 error('threshold too high');
        % % % % %             end
        % % % % %
        % % % % %             % find the first zero crossing after the last active sample
        % % % % %             mask = ones(size(win));
        % % % % %
        % % % % %             zc = false;
        % % % % %             ct = last;
        % % % % %
        % % % % %             while (~zc && ct < last+20)
        % % % % %                 zc = sign(eco(sts(sti)+ct-1)) ~= sign(eco(sts(sti)+ct));
        % % % % %                 ct = ct + 1;
        % % % % %             end
        % % % % %
        % % % % %             mask(1:ct) = 0;
        % % % % %             eco(win) = eco(win) .* mask;
        % % % %         end
        % %
        % %
        % %         eco = bandpass(eco, 1, 200, efs, 4, 'causal');
        % %         eco = notch(eco, [60], efs, 2, 'causal');
        % %
        
        %% preprocess eco
        %             presamps = round(0.050 * efs); % pre time in sec
        presamps = round(0.025 * efs); % pre time in sec
        
        % miah had 0.120
        postsamps = round(0.120 * efs); % post time in sec, % modified DJC to look at up to 300 ms after
        
        sts = round(stims(2,:) / fac);
        edd = zeros(size(sts));
        
        
        temp = squeeze(getEpochSignal(eco', sts-presamps, sts+postsamps+1));
        foo = mean(temp,2);
        lastsample = round(0.040 * efs);
        foo(lastsample:end) = foo(lastsample-1);
        
        last = find(abs(zscore(foo))>1,1,'last');
        last2 = find(abs(diff(foo))>30e-6,1,'last')+1;
        
        zc = false;
        
        if (isempty(last2))
            if (isempty(last))
                error ('something seems wrong in the triggered average');
            else
                ct = last;
            end
        else
            if (isempty(last))
                ct = last2;
            else
                ct = max(last, last2);
            end
        end
        
        while (~zc && ct <= length(foo))
            zc = sign(foo(ct-1)) ~= sign(foo(ct));
            ct = ct + 1;
        end
        
        if (ct > max(last, last2) + 0.10 * efs) % marched along more than 10 msec, probably gone to far
            ct = max(last, last2);
        end
        
%         % DJC - 8-31-2015 - i believe this is messing with the resizing
%         % in the figures
%         %             subplot(8,8,chan);
%         %             plot(foo);
%         %             vline(ct);
%         %
        for sti = 1:length(sts)
            win = (sts(sti)-presamps):(sts(sti)+postsamps+1);
            
            %             interpolation approach
            eco(win(presamps:(ct-1))) = interp1([presamps-1 ct], eco(win([presamps-1 ct])), presamps:(ct-1));
        end
        % ORIGINAL ORDER WAS bandpass, notch
        % try reversing it DJC, 2/11/2016
        
%                 eco = toRow(bandpass(eco, 1, 40, efs, 4, 'causal'));
% original notch below 
%                 eco = toRow(notch(eco, 60, efs, 2, 'causal'));
% 2-26-2016 - my attempt for ecb43e 
                eco = toRow(notch(eco, [60 120 180], efs, 2, 'causal'));
        %
        %
        %% process triggers
        
        if (strcmp(sid, '8adc5c'))
            pts = stims(3,:)==0;
        elseif (strcmp(sid, 'd5cd55'))
            %         pts = stims(3,:)==0 & (stims(2,:) > 4.5e6);
            pts = stims(3,:)==0 & (stims(2,:) > 4.5e6) & (stims(2, :) > 36536266);
        elseif (strcmp(sid, 'c91479'))
            pts = stims(3,:)==0;
        elseif (strcmp(sid, '7dbdec'))
            pts = stims(3,:)==0;
        elseif (strcmp(sid, '9ab7ab'))
            pts = stims(3,:)==0;
        elseif (strcmp(sid, '702d24'))
            pts = stims(3,:)==0;
            %modified DJC 7-27-2015
        elseif (strcmp(sid, 'ecb43e'))
            pts = stims(3,:) == 0;
        elseif (strcmp(sid, '0b5a2e'))
            pts = stims(3,:) == 0;
        else
            error 'unknown sid';
        end
        
        % changing presamps - DJC - 2/24/2016
        presamps = round(0.1*efs);
        postsamps = round(0.120*efs);
        
        ptis = round(stims(2,pts)/fac);
        
        t = (-presamps:postsamps)/efs;
        
        % 2/24/2016 - change CT so that if you pick different limits for
        % pre and post baseline, then you're ok for "blanking out" the
        % stimulation
        
        index = find(t==0);
        ct = index + ct - round(0.025*efs);
        
        
        wins = squeeze(getEpochSignal(eco', ptis-presamps, ptis+postsamps+1));
        %     awins = adjustStims(wins);
        % normalize the windows to each other, using pre data
        awins = wins-repmat(mean(wins(t<0,:),1), [size(wins, 1), 1]);
        %         awins = wins;
        
        pstims = stims(:,pts);
        
        % calculate EP statistics
        stats = quantifyEPs(t, awins);
        
        
        % considered a baseline if it's been at least N seconds since the last
        % burst ended
        
        baselines = pstims(5,:) > 2 * fs;
        
        % modified 9-10-2015 - DJC, find pre condition for each type of
        % test pulse
        
        pre = pstims(7,:) < 0.250*fs;
        
        if (sum(baselines) < 100)
            warning('N baselines = %d.', sum(baselines));
        end
        
        types = unique(bursts(5,pstims(4,:)));
        
        %DJC - modify suffix to list conditioning type
        suffix = arrayfun(@(x) num2str(x), types, 'uniformoutput', false);
        %
        suffix = cell(1,4);
        suffix{1} = 'Negative peak of Beta';
        suffix{2} = 'Positive peak of Beta';
        suffix{3} = 'null condition';
        suffix{4} = 'Random phase of Beta';
        
        nullType = 2;
        
        for typei = 1:length(types)
            if (types(typei) ~= nullType)
                %     % if (all)
                %     probes = pstims(5,:) < .250*fs;
                %     % if (falling)
                probes = pstims(5,:) < .250*fs & bursts(5,pstims(4,:))==types(typei);
                %     if (rising)
                %         probes = pstims(5,:) < .250*fs * bursts(5,pstims(4,:))==1;
                
                if (sum(probes) < 100)
                    warning('N probes = %d.', sum(probes));
                end
                
                label = bursts(4,pstims(4,:));
                label(baselines) = 0;
                %modify this to change groupings/stratifications - djc 8/31/2015
                
                labelGroupStarts = [1 3 5];
                %                 labelGroupStarts = 1:10;
                %     labelGroupStarts = 1:5;
                labelGroupEnds   = [labelGroupStarts(2:end) Inf];
                
                for gIdx = 1:length(labelGroupStarts)
                    labeli = label >= labelGroupStarts(gIdx) & label < labelGroupEnds(gIdx);
                    label(labeli) = gIdx;
                end
                
                keeps = probes | baselines;
                
                %     lows = awins(awins==repmat(min(awins(180:320,keeps)), size(awins,1), 1));
                %     figure
                %     scatter(jitter(label, 0.1), lows)
                
                load('line_colormap.mat');
                kwins = awins(:, keeps);
                klabel = label(keeps);
                ulabels = unique(klabel);
                colors = cm(round(linspace(1, size(cm, 1), length(ulabels))), :);
                
                %% attempt at anova, multiple comparisons
                a1 = 1e6*max(abs((awins(t>0.010 & t < 0.030,keeps))));
                a1Median = median(a1);
                a1 = a1 - median(a1(label(keeps)==0));
                                
                % DJC 4/4/2016 - save just a, so don't get rid of baseline yet
                a = 1e6*max(abs((awins(t>0.01 & t < 0.030,keeps))));
                dataForAnova{chan}{typei} = {a label keeps};
                
                [anova,table,stats] = anova1(a1', label(keeps), 'off');
                [c,m,h,gnames] = multcompare(stats,'display','off');
                sigChans{chan}{typei} = {m c a1Median a1 label keeps};

                
                %% zscore dat
                for i = 1:length(ulabels)-1
                    total = 1e6*(awins(:,keeps));
                    base = 1e6*(awins(:,label(keeps)==0));
                    test = 1e6*(awins(:,label(keeps)==i));
                    [zT,magT,latT] = zscoreCCEP(total,test,t);
                    [zB,magB,latB] = zscoreCCEP(total,base,t);
                    CCEPbyNumStim{chan}{typei}{i} = {zT magT latT zB magB latB};
                end
                
                                
                % zscore INDIVIDUAL FOR ANOVA 4-7-2016 DJC 
                total = 1e6*(awins(:,keeps));

                [~,~,~,zI,magI,latencyIms] = zscoreCCEP(total,total,t);
                ZscoredDataForAnova{chan}{typei} = {zI label keeps magI latencyIms};
                
                %% - DJC 2-23-2016 - looking at erp_perm_test
                
%                 extractedSigs = 1e6*((awins(t>0.010 & t<0.030,keeps)));
                
                %%
                
                if anova < 0.05
%                     figure
%                     set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
%                     subplot(3,1,1);
%                     
%                     % original
%                     prettyline(1e3*t,1e6*awins(:, keeps), label(keeps), colors);
%                     %
%                     %                 % try subtracting mean of baselines, DJC 2-4-2016, post
%                     %                 % convo with miah
%                     xlim(1e3*[-0.025 max(t)]);
%                     
%                     %                     xlim(1e3*[min(t) max(t)]);
%                     yl = ylim;
%                     yl(1) = min(-10, max(yl(1),-140));
%                     yl(2) = max(10, min(yl(2),100));
%                     ylim(yl);
%                     highlight(gca, [0 t(ct)*1e3], [], [.5 .5 .5]) %this is the part that plots that stim window
%                     vline(0);
%                     xlabel('time (ms)');
%                     ylabel('ECoG (uV)');
%                     %                 title(sprintf('EP By N_{CT}: %s, %d, {%s}', sid, chan, suffix{typei}))
%                     title(sprintf('%s CCEPs for Channel %d stimuli in {%s}',sid,chan,suffix{typei}))
%                     leg = {'Pre'};
%                     for d = 1:length(labelGroupStarts)
%                         if d == length(labelGroupStarts)
%                             leg{end+1} = sprintf('%d<=CT', labelGroupStarts(d));
%                         else
%                             leg{end+1} = sprintf('%d<=CT<%d', labelGroupStarts(d), labelGroupEnds(d));
%                         end
%                     end
%                     leg{end+1} = 'Stim Window';
%                     %     leg{end+1} = 'EP_P';
%                     legend(leg, 'location', 'Southeast')
%                     
%                     %
%                     % try zscore?
%                     %                                 prettyline(1e3*t((1e3*t)>10), zscore(1e6*awins((1e3*t)>10, keeps)), label(keeps), colors);
%                     %     ylim([-130 50]);
%                     
%                     % second mean subtracted
%                     
%                     subplot(3,1,2)
%                     prettyline(1e3*t, bsxfun(@minus,1e6*awins(:, keeps),1e6*median(awins(:,baselines),2)), label(keeps), colors);
%                     
%                     
%                     % changed DJC 1-7-2016
%                     xlim(1e3*[-0.025 max(t)]);
%                     
%                     %                     xlim(1e3*[min(t) max(t)]);
%                     %                 xlim([-5 300]);
%                     %     vline([6 20 40], 'k');
%                     %     highlight(gca, [25 33], [], [.6 .6 .6])
%                     %             highlight(gca, [0 4], [], [.3 .3 .3]);
%                     %             vline(0.030*1e3);
%                     %             vline(0.080*1e3);
%                     yl = ylim;
%                     yl(1) = min(-10, max(yl(1),-140));
%                     yl(2) = max(10, min(yl(2),100));
%                     ylim(yl);
%                     highlight(gca, [0 t(ct)*1e3], [], [.5 .5 .5]) %this is the part that plots that stim window
%                     vline(0);
%                     %                 vline(80);
%                     
%                     % DJC - 2-11-2016 - set y limits for z-score
%                     %                 ylim([-2 2])
%                     
%                     xlabel('time (ms)');
%                     ylabel('ECoG (uV)');
%                     title('Median Subtracted')
%                     
%                     %                 title(sprintf('EP By N_{CT}: %s, %d, {%s}', sid, chan, suffix{typei}))
%                     %                     title(sprintf('%s CCEPs for Channel %d stimuli in {%s}',sid,chan,suffix{typei}))
%                     %                     leg = {'Pre'};
%                     %                     for d = 1:length(labelGroupStarts)
%                     %                         if d == length(labelGroupStarts)
%                     %                             leg{end+1} = sprintf('%d<=CT', labelGroupStarts(d));
%                     %                         else
%                     %                             leg{end+1} = sprintf('%d<=CT<%d', labelGroupStarts(d), labelGroupEnds(d));
%                     %                         end
%                     %                     end
%                     %                     leg{end+1} = 'Stim Window';
%                     %                     %     leg{end+1} = 'EP_P';
%                     %                     legend(leg, 'location', 'Southeast')
%                     %
%                     
%                     %% added DJC 2-11-2016 to try and do quick stats
%                     % start with negative surface deflection 10 -> 30
%                     
%                     
%                     %                 figure
%                     subplot(3,1,3)
%                     prettybar(a1, label(keeps), colors, gcf);
%                     set(gca, 'xtick', []);
%                     ylabel('\DeltaEP_N (uV)');
%                     
%                     title(sprintf('Change in EP_N by N_{CT}: One-Way Anova F=%4.2f p=%0.4f', table{2,5}, table{2,6}));
%                     %                                     figure
%                     %                                     [pCond,tblCond,statsCond] = kruskalwallis(a1',label(keeps));
%                     %
%                                         SaveFig(OUTPUT_DIR, sprintf(['epSTATS-%s-%dFILT' suffix{typei}], sid, chan), 'eps', '-r600');
%                                         SaveFig(OUTPUT_DIR, sprintf(['epSTATS-%s-%dFILT' suffix{typei}], sid, chan), 'png', '-r600');
%               close 
                end
                %%
                %                 figure
                %                 %     subplot(2,2,1:2);
                %
                %                 % try subtracting the mean, other idea is to build two
                %                 % distributions from zscore
                %                 % 2-4-2016 - DJC post conversation with Miah
                %
                %
                %                 % original
                %                 %                 prettyline(1e3*t,1e6*awins(:, keeps), label(keeps), colors);
                %
                %                 % try subtracting mean of baselines, DJC 2-4-2016, post
                %                 % convo with miah
                %
                %                 prettyline(1e3*t, bsxfun(@minus,1e6*awins(:, keeps),1e6*mean(awins(:,baselines),2)), label(keeps), colors);
                %
                %                 % try zscore?
                %                 %                 prettyline(1e3*t((1e3*t)>10), zscore(1e6*awins((1e3*t)>10, keeps)), label(keeps), colors);
                %
                %                 %     ylim([-130 50]);
                %
                %                 %     ylim([-130 50]);
                %
                %                 % xlim modified by DJC 1-7-2016
                %
                %                 %                 xlim(1e3*[min(t) max(t)]);
                %                 xlim([-5 80]);
                %
                %
                %                 %     vline([6 20 40], 'k');
                %                 %     highlight(gca, [25 33], [], [.6 .6 .6])
                %                 %             highlight(gca, [0 4], [], [.3 .3 .3]);
                %                 %             vline(0.030*1e3);
                %                 %             vline(0.080*1e3);
                %                 yl = ylim;
                %                 yl(1) = min(-10, max(yl(1),-140));
                %                 yl(2) = max(10, min(yl(2),100));
                %                 ylim(yl);
                %
                %                 % 2-10-2016 zscore ylim
                %                 %                 ylim([-5 5])
                %
                %                 xlim([-5 80]);
                %                 highlight(gca, [0 t(ct)*1e3], [], [.8 .8 .8]) %this is the part that plots that stim window
                %                 vline(0);
                %
                %                 xlabel('time (ms)');
                %                 ylabel('ECoG (uV)');
                %                 %                 title(sprintf('EP By N_{CT}: %s, %d, {%s}', sid, chan, suffix{typei}))
                %                 title(sprintf('%s CCEPs for Channel %d, stimuli in %s ',sid,chan,suffix{typei}))
                %
                %                 %1-7-2016 - below is for d5cd55
                %                 %                 title(sprintf('%s CCEPs for Channel %d, stimuli on zero crossing ',sid,chan))
                %
                %                 leg = {'Pre'};
                %                 for d = 1:length(labelGroupStarts)
                %                     if d == length(labelGroupStarts)
                %                         leg{end+1} = sprintf('%d<=CT', labelGroupStarts(d));
                %                     else
                %                         leg{end+1} = sprintf('%d<=CT<%d', labelGroupStarts(d), labelGroupEnds(d));
                %                     end
                %                 end
                %                 leg{end+1} = 'Stim Window';
                %                 %     leg{end+1} = 'EP_P';
                %                 legend(leg, 'location', 'Southeast')
                %
                %                 %% added DJC 2-11-2016 to try and do quick stats
                %                 a1 = 1e6*max(awins(t>0.010 & t < 0.040,keeps));
                %                 a1 = a1 - mean(a1(label(keeps)==0));
                %
                %                 figure
                %                 subplot(2,1,1)
                %                 prettybar(a1, label(keeps), colors, gcf);
                %                 set(gca, 'xtick', []);
                %                 ylabel('\DeltaEP_N (uV)');
                %                 [~,table] = anova1(dep_n', label(keeps), 'off');
                %                 title(sprintf('Change in EP_N by N_{CT}: One-Way Anova F=%4.2f p=%0.4f', table{2,5}, table{2,6}));
                %
                %
                %                 pair = {};
                %                 p = [];
                %                 ulabels = unique(label);
                %                 for c = 2:length(ulabels)
                %                     [~,p(c-1)] = ttest2(dep_n(label(keeps)==0), dep_n(label(keeps)==ulabels(c)));
                %                     pair{c-1} = {1,c};
                %                 end
                %                 ylim([-12 15]);
                %
                %                 sigstar(pair, p);
                %
                %                 subplot(2,1,2);
                %                 prettybar(a1, label(keeps), colors, gcf);
                %                 set(gca, 'xtick', []);
                %                 ylabel('\DeltaEP_P (uV)');
                %                 [~,table] = anova1(a1', label(keeps), 'off');
                %                 title(sprintf('Change in EP_P by N_{CT}: One-Way Anova F=%4.2f p=%0.4f', table{2,5}, table{2,6}));
                %
                %                 pair = {};
                %                 p = [];
                %                 ulabels = unique(label);
                %                 for c = 2:length(ulabels)
                %                     [~,p(c-1)] = ttest2(a1(label(keeps)==0), a1(label(keeps)==ulabels(c)));
                %                     pair{c-1} = {1,c};
                %                 end
                %                 ylim([-12 15]);
                %
                %                 sigstar(pair, p);
                %
                %                 %                                     dep_n = 1e6*min(awins(t>0.005 & t < 0.020, keeps));
                %                 %                                     dep_n = dep_n - mean(dep_n(label(keeps)==0));
                %                 %
                %                 %                                     dep_p = 1e6*max(awins(t>0.025 & t < 0.033, keeps));
                %                 %                                     dep_p = dep_p - mean(dep_p(label(keeps)==0));
                %                 %
                %                 %                                     subplot(2,2,3);
                %                 %                                     prettybar(dep_n, label(keeps), colors, gcf);
                %                 %                                     set(gca, 'xtick', []);
                %                 %                                     ylabel('\DeltaEP_N (uV)');
                %                 %                                     [~,table] = anova1(dep_n', label(keeps), 'off');
                %                 %                                     title(sprintf('Change in EP_N by N_{CT}: One-Way Anova F=%4.2f p=%0.4f', table{2,5}, table{2,6}));
                %                 %
                %                 %                                     pair = {};
                %                 %                                     p = [];
                %                 %                                     ulabels = unique(label);
                %                 %                                     for c = 2:length(ulabels)
                %                 %                                         [~,p(c-1)] = ttest2(dep_n(label(keeps)==0), dep_n(label(keeps)==ulabels(c)));
                %                 %                                         pair{c-1} = {1,c};
                %                 %                                     end
                %                 %                                     ylim([-12 15]);
                %                 %
                %                 %                                     sigstar(pair, p);
                %                 %
                %                 %                                     subplot(2,2,4);
                %                 %                                     prettybar(dep_p, label(keeps), colors, gcf);
                %                 %                                     set(gca, 'xtick', []);
                %                 %                                     ylabel('\DeltaEP_P (uV)');
                %                 %                                     [~,table] = anova1(dep_p', label(keeps), 'off');
                %                 %                                     title(sprintf('Change in EP_P by N_{CT}: One-Way Anova F=%4.2f p=%0.4f', table{2,5}, table{2,6}));
                %                 %
                %                 %                                     pair = {};
                %                 %                                     p = [];
                %                 %                                     ulabels = unique(label);
                %                 %                                     for c = 2:length(ulabels)
                %                 %                                         [~,p(c-1)] = ttest2(dep_p(label(keeps)==0), dep_p(label(keeps)==ulabels(c)));
                %                 %                                         pair{c-1} = {1,c};
                %                 %                                     end
                %                 %                                     ylim([-12 15]);
                %                 %
                %                 %                                     sigstar(pair, p);
                
%                 SaveFig(OUTPUT_DIR, sprintf(['ep-%s-%dUNFILT' suffix{typei}], sid, chan), 'eps', '-r600');
%                 SaveFig(OUTPUT_DIR, sprintf(['ep-%s-%dUNFILT' suffix{typei}], sid, chan), 'png', '-r600');
                
                %                 saveFigure(gcf,fullfile(OUTPUT_DIR, sprintf('ep-%s-%d.eps', sid, chan)), 'eps', '-r600');
                %                 saveas(gcf,fullfile(OUTPUT_DIR, sprintf('ep-%s-%d.eps', sid, chan)),'eps','-r600');
            end
            if strcmp('ecb43e',sid)
                sigChans{64} = [];
            end
        end
        
    end
    save(fullfile(OUTPUT_DIR, [sid 'epSTATSsig.mat']), 'sigChans','CCEPbyNumStim','dataForAnova','ZscoredDataForAnova');
    
end