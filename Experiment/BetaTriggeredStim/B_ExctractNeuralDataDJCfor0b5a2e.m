%% Constants
close all; clear all;clc
% cd 'C:\Users\David\Desktop\Research\RaoLab\MATLAB\Code\Experiment\BetaTriggeredStim'
Z_Constants;
addpath ./scripts/ %DJC edit 7/20/2015;

SUB_DIR = fullfile(myGetenv('subject_dir'));
% OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'));

%% parameters
% FOR 0b5a2e
% need to be fixed to be nonspecific to subject
% SIDS = SIDS(2:end);
SIDS = SIDS(8);
%%
for idx = 1:length(SIDS)
    %%
    idx = 1;
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
            
            goods = sort([44 45 46 52 53 55 60 61 63]);
            betaChan = 53;
            
            % have to set t_min and t_max for each subject
            %t_min = 0.004833;
            % t_min of 0.005 would find the really early ones
            t_min = 0.008;
            t_max = 0.05;
            
        case 'c91479'
            % sid = SIDS{3};
            tp = strcat(SUB_DIR,'\c91479\data\d7\c91479_BetaTriggeredStim');
            block = 'BetaPhase-14';
            stims = [55 56];
            chans = [64 63 48];
            betaChan = 64;
            goods = sort([ 39 40 47 48 63 64]);
            t_min = 0.008;
            t_max = 0.035;
        case '7dbdec'
            % sid = SIDS{4};
            tp = strcat(SUB_DIR,'\7dbdec\data\d7\7dbdec_BetaTriggeredStim');
            block = 'BetaPhase-17';
            stims = [11 12];
            chans = [4 5 14];
            goods = sort([4 5 10 13]);
            betaChan = 4;
            t_min = 0.005;
            t_max = 0.05;
        case '9ab7ab'
            %             sid = SIDS{5};
            tp = strcat(SUB_DIR,'\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim');
            block = 'BetaPhase-3';
            stims = [59 60];
            chans = [51 52 53 58 57];
            % chans = 29;
            betaChan = 51;
            
            goods = sort([42 43 49 50 51 52 53 57 58]);
            t_min = 0.005;
            t_max = 0.0425;
        case '702d24'
            tp = strcat(SUB_DIR,'\702d24\data\d7\702d24_BetaStim');
            block = 'BetaPhase-4';
            stims = [13 14];
            chans = [4 5 21];
            goods = [ 5 ];
            bads = [23 27 28 29 30 32];
            t_min = 0.008;
            t_max = 0.0425;
            
        case 'ecb43e' % added DJC 7-23-2015
            tp = strcat(SUB_DIR,'\ecb43e\data\d7\BetaStim');
            block = 'BetaPhase-3';
            stims = [56 64];
            chans = [47 55];
            betaChan = 55;
            goods = sort([55 63 54 47 48]);
            t_min = 0.008;
            t_max = 0.05;
        case '0b5a2e' % added DJC 7-23-2015
            tp = strcat(SUB_DIR,'\0b5a2e\data\d8\0b5a2e_BetaStim\0b5a2e_BetaStim');
            block = 'BetaPhase-2';
            stims = [22 30];
            %             chans = [23 31 21 14 15 32 40];
            % DJC 2-5-2016 - prototype just on channel 23
            chans = [1:64];
            %chans = [14 23 31];
            %                         chans = [23];
            %             chans = [14 15 23 24 26 33 34 35 39 40 42 43];
            betaChan = 23;
            %goods = sort([12 13 14 15 16 20 21 23 31 32 39 40]);
            goods = [14 21 23 31];
            bads = [20 24 28];
            t_min = 0.008;
            t_max = 0.05;
        case '0b5a2ePlayback' % added DJC 7-23-2015
            tp = strcat(SUB_DIR,'\0b5a2e\data\d8\0b5a2e_BetaStim\0b5a2e_BetaStim');
            block = 'BetaPhase-4';
            stims = [22 30];
            %             chans = [23 31 21 14 15 32 40];
            %             chans = [23 31];
            %             chans = 23;
            chans = [1:64];
            %             chans = 40;
            betaChan = 31;
            goods = sort([12 13 14 15 16 21 23 31 32 39 40]);
            bads = [20 24 28];
            t_min = 0.005;
            t_max = 0.05;
        case '0a80cf' % added DJC 5-24-2016
            tp = strcat(SUB_DIR,'\0a80cf\data\d10\0a80cf_BetaStim\0a80cf_BetaStim');
            block = 'BetaPhase-4';
            
            stims = [27 28];
            %             chans = [23 31 21 14 15 32 40];
            %             chans = [23 31];
            %             chans = 23;
            chans = [1:64];
            %             chans = 40;
            
        case '3f2113' % added DJC 7-23-2015
            tp =  strcat(SUB_DIR,'\',sid,'\data\data\d6\BetaStim\BetaStim');
            block = 'BetaPhase-5';
            stims = [32 31];
            %             chans = [23 31 21 14 15 32 40];
            % DJC 2-5-2016 - prototype just on channel 23
            chans = [1:64];
            %chans = [14 23 31];
            %                         chans = [23];
            %             chans = [14 15 23 24 26 33 34 35 39 40 42 43];
            betaChan = 40;
            t_min = 0.005;
            t_max = 0.05;
        otherwise
            error('unknown SID entered');
    end
    
    chans(ismember(chans, stims)) = [];
    
    %% load in the trigger data
    % 9-2-2015 DJC added mod DJC
    
    tank = TTank;
    tank.openTank(tp);
    tank.selectBlock(block);
    
    if strcmp(sid,'0b5a2ePlayback')
        load(fullfile(META_DIR, ['0b5a2e' '_tables_modDJC.mat']), 'bursts', 'fs', 'stims');
        
        % this was for discovering the delay, now it's known to be about
        % 577869
        %         tic;
        %         [smon, info] = tank.readWaveEvent('SMon', 2);
        %         smon = smon';
        %
        %         fs = info.SamplingRateHz;
        %
        %         stim = tank.readWaveEvent('SMon', 4)';
        %         toc;
        %
        %         tic;
        %         mode = tank.readWaveEvent('Wave', 2)';
        %         ttype = tank.readWaveEvent('Wave', 1)';
        %
        %         beta = tank.readWaveEvent('Blck', 1)';
        %
        %         raw = tank.readWaveEvent('Blck', 2)';
        %
        %         toc;
        
        delay = 577869;
    else
        
        % below is for original miah style burst tables
        %         load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts', 'fs', 'stims');
        % below is for modified burst tables
        load(fullfile(META_DIR, [sid '_tables_modDJC.mat']), 'bursts', 'fs', 'stims');
    end
    % drop any stims that happen in the first 500 milliseconds
    stims(:,stims(2,:) < fs/2) = [];
    
    % drop any probe stimuli without a corresponding pre-burst/post-burst
    bads = stims(3,:) == 0 & (isnan(stims(4,:)) | isnan(stims(6,:)));
    stims(:, bads) = [];
    
    
    % adjust stim and burst tables for 0b5a2e playback case
    
    if strcmp(sid,'0b5a2ePlayback')
        
        stims(2,:) = stims(2,:)+delay;
        bursts(2,:) = bursts(2,:) + delay;
        bursts(3,:) = bursts(3,:) + delay;
        
    end
    
    
    
    %figure
    %% process each ecog channel individually
    
    sigChans = {};
    shuffleChans = {};
    CCEPbyNumStim = {};
    
    % 4/4/2016 - added data for anova
    dataForAnova = {};
    
    % 4/7/2016 - Zscored data for anova
    ZscoredDataForAnova = {};
    chans = betaChan;
    for chan = goods
        
        %% load in ecog data for that channel
        fprintf('loading in ecog data for:\n',sid);
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
        
        %% preprocess eco
        %             presamps = round(0.050 * efs); % pre time in sec
        % pre time
        presamps = round(0.025 * efs); % pre time in sec
        
        % if doing zscore, try 0.3, otherwise .120 is good. Looks like
        % conditioning stimuli sometimes begin around 80 ms after? so if
        % you zscore normalize bad news bears
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
        % try getting rid of this part for 0b5a2e to conserve that initial
        % spike DJC 1-7-2016
        while (~zc && ct <= length(foo))
            zc = sign(foo(ct-1)) ~= sign(foo(ct));
            ct = ct + 1;
        end
        % consider 3 ms? DJC - 1-5-2016
        if (ct > max(last, last2) + 0.10 * efs) % marched along more than 10 msec, probably gone to far
            ct = max(last, last2);
        end
        
        % DJC - 8-31-2015 - i believe this is messing with the resizing
        % in the figures
        %             subplot(8,8,chan);
        %             plot(foo);
        %             vline(ct);
        %
        %% INTERPOLATION PART!
        %         for sti = 1:length(sts)
        %             win = (sts(sti)-presamps):(sts(sti)+postsamps+1);
        %
        %             %             interpolation approach
        %             eco(win(presamps:(ct-1))) = interp1([presamps-1 ct], eco(win([presamps-1 ct])), presamps:(ct-1));
        %         end
        % %         tried doing 1-200 rather than 1-40 - DJC 1-7-2016
        %                         eco = toRow(bandpass(eco, 1, 40, efs, 4, 'causal'));
        %                 eco = toRow(notch(eco, 60, efs, 2, 'causal'));
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
        elseif (strcmp(sid, '0b5a2ePlayback'))
            pts = stims(3,:) == 0;
        elseif (strcmp(sid,'3f2113'))
            pts = stims(3,:) == 0;
            
        else
            error 'unknown sid';
        end
        
        
        %         presamps = round(0.10 * efs); % pre time in sec
        
        % if doing zscore, try 0.3, otherwise .120 is good. Looks like
        % conditioning stimuli sometimes begin around 80 ms after? so if
        % you zscore normalize bad news bears
        %         postsamps = round(0.120 * efs); % post time in sec, % modified DJC to look at up to 300 ms after
        
        presamps = round(0.500*efs);
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
        awins = wins-repmat(mean(wins(t<-0.005 & t>-0.05,:),1), [size(wins, 1), 1]);
        %         awins = wins;
        
        pstims = stims(:,pts);
        
        % calculate EP statistics
        stats = quantifyEPs(t, awins);
        
        
        % considered a baseline if it's been at least N seconds since the last
        % burst ended
        
        baselines = pstims(5,:) > 2 * fs;
        
        % modified 9-10-2015 - DJC, find pre condition for each type of
        % test pulse
        
        %         pre = pstims(7,:) < 0.250*fs;
        
        if (sum(baselines) < 100)
            warning('N baselines = %d.', sum(baselines));
        end
        
        types = unique(bursts(5,pstims(4,:)));
        
        %DJC - modify suffix to list conditioning type
        suffix = arrayfun(@(x) num2str(x), types, 'uniformoutput', false);
        %
        suffix = cell(1,3);
        suffix{1} = 'Negative phase of Beta';
        suffix{2} = 'Positive phase of Beta';
        suffix{3} = 'Null Condition';
        
        
        nullType = 2;
        % .250 originally
        
        for typei = 1:length(types)
            if (types(typei) == nullType)
                probes = pstims(5,:) < .250*fs & bursts(5,pstims(4,:))==types(typei);
                if (sum(probes) < 100)
                    warning('N probes = %d.', sum(probes));
                end
                label = bursts(4,pstims(4,:));
                label(baselines) = 0;
                
                label(probes) = 1 ;
                
                keeps = probes | baselines;
                
                load('line_colormap.mat');
                kwins = awins(:, keeps);
                klabel = label(keeps);
                ulabels = unique(klabel);
                colors = cm(round(linspace(1, size(cm, 1), length(ulabels))), :);
                
                %%
                % move stats up here DJC 2-11-2016 in order to only plot if
                % significant
                
                % modified DJC 4/24/2016 -
                % try setting t_min and t_max for each subject 6_17-2016
                %  tMin = 0.01;
                %  tMax = 0.030;
                tMin = t_min;
                tMax = t_max;
                
                a1 = 1e6*max(abs((awins(t>tMin & t < tMax,keeps))));
                a1Median = median(a1);
                a1 = a1 - median(a1(label(keeps)==0));
                
                % DJC - 3-25-2016. Save a1, label(keeps), in order to do
                % multiway anova for channels of interest. Will start with
                % just BETA
                
                % DJC 4/4/2016 - save just a, so don't get rid of baseline yet
                a = 1e6*max(abs((awins(t>tMin & t < tMax,keeps))));
                dataForAnova{chan}{typei} = {a label keeps};
                
                [anovaNull,tableNull,statsNull] = anova1(a1', label(keeps), 'on');
                [c,m,h,gnames] = multcompare(statsNull,'display','on');
                sigChans{chan}{typei} = {m c a1Median a1 label keeps};
                plotIt = false;
                %% zscore dat
                for i = 1:length(ulabels)-1
                    total = 1e6*(awins(:,keeps));
                    %base = 1e6*(awins(:,label(keeps)==0)); %  FIX TIHS
                    % test = 1e6*(awins(:,label(keeps)==i));
                    base = 1e6*(awins(:,label==0 & keeps));
                    test = 1e6*(awins(:,label==i & keeps));
                    
                    %[zT,magT,latT] = zscoreCCEP(total,test,t,tMin,tMax);
                    [zT,magT,latT] = zscoreWithFindPeaks(total,test,t,tMin,tMax,plotIt);
                    %[zB,magB,latB] = zscoreCCEP(total,base,t,tMin,tMax);
                    [zB,magB,latB] = zscoreWithFindPeaks(total,test,t,tMin,tMax,plotIt);
                    
                    
                    CCEPbyNumStim{chan}{typei}{i} = {zT magT latT zB magB latB};
                end
                
                % zscore INDIVIDUAL FOR ANOVA 4-7-2016 DJC
                total = 1e6*(awins(:,keeps));
                %[~,~,~,zI,magI,latencyIms] = zscoreCCEP(total,total,t,tMin,tMax);
                [~,~,~,~,~,zI,magI,latencyIms,~,~] = zscoreWithFindPeaks(total,test,t,tMin,tMax,plotIt);
                
                
                %
                %% - DJC 2-23-2016 - looking at erp_perm_test
                
                
                % need to do for each type
                %                 CCEPbyNumStim = {};
                % dont need to reinitialize CCEPbyNumStim, as it goes
                % through the other way first
                % i is 1 in this case
                
                t_minS = 0.005;
                t_maxS = 0.040;
                
                i = 1;
                Nperm = 1000;
                sp = 95;
                extractedSigs = 1e6*((awins(t>t_minS & t<t_maxS,keeps)));
                extractedSigsBase = extractedSigs(:,label==0 & keeps);
                extractedSigsTest = extractedSigs(:,label==i & keeps);
                
                tExtract = t(t>t_minS & t<t_maxS);
                figure
                plot(tExtract,extractedSigsBase,'b',tExtract,extractedSigsTest,'r');
                hold on
                plot(tExtract,mean(extractedSigsBase,2),'g','Linewidth',[4])
                plot(tExtract,mean(extractedSigsTest,2),'y','Linewidth',[4]);
                
                
                [CI_loNull, CI_hiNull, sgcNull] = stavrosShuffle(extractedSigsBase,extractedSigsTest,Nperm,sp);
                
                hold on
                bar(tExtract,100*sgcNull,'linewidth',[2])
                % from mathworks to find continuous segment that was at
                % least 3 ms long?
                
                tSearch = diff([false;sgcNull==1;false]);
                p = find(tSearch==1);
                q = find(tSearch==-1);
                [maxlen,ix] = max(q-p);
                firstSearch = p(ix);
                lastSearch = q(ix)-1;
                
                CCEPmed = median(extractedSigs(:,klabel==i),2);
                [minval,inx] = min(CCEPmed);
                % account for case where inx = 1 to avoid addressing matrix
                % outside of bounds
                if inx == 1
                    inx = inx + 1;
                end
                CCEPmag = (CCEPmed(inx)+CCEPmed(inx-1)+CCEPmed(inx+1))/3;
                CCEPbyNumStimNull{i} = CCEPmag;
                
                %
                %                 if anova < 0.05
                figure
                % this sets the figure to be the whole screen
                set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
                subplot(3,1,1);
                
                % try subtracting the mean, other idea is to build two
                % distributions from zscore
                % 2-4-2016 - DJC post conversation with Miah
                
                
                % original
                prettyline(1e3*t,1e6*awins(:, keeps), label(keeps), colors);
                % xlim(1e3*[-0.025 max(t)]);
                
                xlim(1e3*[min(t) max(t)]);
                yl = ylim;
                yl(1) = min(-10, max(yl(1),-140));
                yl(2) = max(10, min(yl(2),100));
                ylim(yl);
                highlight(gca, [0 t(ct)*1e3], [], [.5 .5 .5]) %this is the part that plots that stim window
                vline(0);
                xlabel('time (ms)');
                ylabel('ECoG (uV)');
                %                 title(sprintf('EP By N_{CT}: %s, %d, {%s}', sid, chan, suffix{typei}))
                title(sprintf('%s CCEPs for Channel %d, Null Condition',sid,chan))
                leg = {'Pre','Post'};
                
                leg{end+1} = 'Stim Window';
                %     leg{end+1} = 'EP_P';
                legend(leg, 'location', 'Southeast')
                % try subtracting mean of baselines, DJC 2-4-2016, post
                % convo with miah
                subplot(3,1,2)
                
                prettyline(1e3*t, bsxfun(@minus,1e6*awins(:, keeps),1e6*median(awins(:,baselines),2)), label(keeps), colors);
                
                % try zscore?
                
                
                %     ylim([-130 50]);
                
                % changed DJC 1-7-2016 to look at -8 to 80
                % xlim(1e3*[-0.025 max(t)]);
                xlim(1e3*[min(t) max(t)]);
                %                 xlim([-5 300]);
                
                %     vline([6 20 40], 'k');
                %     highlight(gca, [25 33], [], [.6 .6 .6])
                %             highlight(gca, [0 4], [], [.3 .3 .3]);
                %             vline(0.030*1e3);
                %             vline(0.080*1e3);
                yl = ylim;
                yl(1) = min(-10, max(yl(1),-140));
                yl(2) = max(10, min(yl(2),100));
                ylim(yl);
                % DJC - ylim for zscores
                %                                 ylim([-2 2])
                
                % DJC set highlight to 1 1 1 to block it out
                highlight(gca, [0 t(ct)*1e3], [], [.5 .5 .5]) %this is the part that plots that stim window
                
                vline(0);
                %                 vline(80);
                
                
                xlabel('time (ms)');
                ylabel('ECoG (uV)');
                %                 title(sprintf('EP By N_{CT}: %s, %d, {%s}', sid, chan, suffix{typei}))
                title('Median Subtracted')
                %                     leg = {'Pre','Post'};
                %
                %                     leg{end+1} = 'Stim Window';
                %                     %     leg{end+1} = 'EP_P';
                %                     legend(leg, 'location', 'Southeast')
                
                
                %% added DJC 2-11-2016 to try and do quick stats
                
                subplot(3,1,3)
                %                 figure
                prettybar(a1, label(keeps), colors, gcf);
                set(gca, 'xtick', []);
                ylabel('\DeltaEP_N (uV)');
                title(sprintf('Change in EP_N by N_{CT}: One-Way Anova F=%4.2f p=%0.4f', tableNull{2,5}, tableNull{2,6}));
                %                                     figure
                figure
                [pNull,tblNull,statsNull] = kruskalwallis(a1',label(keeps));
                
                %
                %                     SaveFig(OUTPUT_DIR, sprintf(['epSTATS-%s-%dUNFILT' suffix{typei}], sid, chan), 'eps', '-r600');
                %                     SaveFig(OUTPUT_DIR, sprintf(['epSTATS-%s-%dUNFILT' suffix{typei}], sid, chan), 'png', '-r600');
                % %
                %                 end
                %                 shuffleChansNull{chan} = {CI_loNull CI_hiNull sgcNull CCEPbyNumStimNull};
            elseif (types(typei) ~= nullType)
                %     % if (all)
                %     probes = pstims(5,:) < .250*fs;
                %     % if (falling)
                
                
                % time window for probes, originally < 0.250*fs, test
                % further out
                
                
                probes = pstims(5,:) < 0.250*fs & bursts(5,pstims(4,:))==types(typei);                %     if (rising)
                %         probes = pstims(5,:) < .250*fs * bursts(5,pstims(4,:))==1;
                
                if (sum(probes) < 100)
                    warning('N probes = %d.', sum(probes));
                end
                
                label = bursts(4,pstims(4,:));
                label(baselines) = 0;
                %modify this to change groupings/stratifications - djc 8/31/2015
                
                labelGroupStarts = [1 3 5];
                %                                 labelGroupStarts = 1:10;
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
                
                %%
                % try setting t_min and t_max for each subject 6_17-2016
                %  tMin = 0.01;
                %  tMax = 0.030;
                tMin = t_min;
                tMax = t_max;
                
                a1 = 1e6*max(abs((awins(t>tMin & t < tMax,keeps))));
                a1Median = median(a1);
                a1 = a1 - median(a1(label(keeps)==0));
                
                % DJC - 3-25-2016. Save a1, label(keeps), in order to do
                % multiway anova for channels of interest. Will start with
                % just BETA
                
                % DJC 4/4/2016 - save just a, so don't get rid of baseline yet
                a = 1e6*max(abs((awins(t>tMin & t < tMax,keeps))));
                dataForAnova{chan}{typei} = {a label keeps};
                
                [anova,table,stats] = anova1(a1', label(keeps), 'on');
                [c,m,h,gnames] = multcompare(stats,'display','on');
                sigChans{chan}{typei} = {m c a1Median a1 label keeps};
                % using 6_16_2016 zscore peak finder modifications
                plotIt = false;
                %% zscore dat
                for i = 1:length(ulabels)-1
                    total = 1e6*(awins(:,keeps));
                    base = 1e6*(awins(:,label(keeps)==0));
                    test = 1e6*(awins(:,label(keeps)==i));
                    %[zT,magT,latT] = zscoreCCEP(total,test,t,tMin,tMax);
                    [zT,magT,latT] = zscoreWithFindPeaks(total,test,t,tMin,tMax,plotIt);
                    %[zB,magB,latB] = zscoreCCEP(total,base,t,tMin,tMax);
                    [zB,magB,latB] = zscoreWithFindPeaks(total,test,t,tMin,tMax,plotIt);
                    
                    
                    CCEPbyNumStim{chan}{typei}{i} = {zT magT latT zB magB latB};
                end
                
                % zscore INDIVIDUAL FOR ANOVA 4-7-2016 DJC
                total = 1e6*(awins(:,keeps));
                %[~,~,~,zI,magI,latencyIms] = zscoreCCEP(total,total,t,tMin,tMax);
                [~,~,~,~,~,zI,magI,latencyIms,~,~] = zscoreWithFindPeaks(total,total,t,tMin,tMax,plotIt);
                
                ZscoredDataForAnova{chan}{typei} = {zI label keeps magI latencyIms};
                %% trying stavros method
                shuffleSig = 0;
                if shuffleSig
                    % need to do for each type
                    CCEPbyNumStim = {};
                    for i = 1:length(ulabels)-1
                        Nperm = 1000;
                        sp = 95;
                        
                        t_minS = 0.005;
                        t_maxS = 0.040;
                        
                        extractedSigs = 1e6*((awins(t>t_minS & t<t_maxS,keeps)));
                        extractedSigsBase = extractedSigs(:,label(keeps)==0);
                        extractedSigsTest = extractedSigs(:,label(keeps)==i);
                        tExtract = t(t>t_minS & t<t_maxS);
                        figure
                        plot(tExtract,extractedSigsBase,'b',tExtract,extractedSigsTest,'r');
                        hold on
                        plot(tExtract,mean(extractedSigsBase,2),'g','Linewidth',[4])
                        plot(tExtract,mean(extractedSigsTest,2),'y','Linewidth',[4]);
                        
                        
                        [CI_lo, CI_hi, sgc] = stavrosShuffle(extractedSigsBase,extractedSigsTest,Nperm,sp);
                        
                        hold on
                        bar(tExtract,100*sgc,'linewidth',[2])
                        % from mathworks to find continuous segment that was at
                        % least 3 ms long?
                        
                        tSearch = diff([false;sgc==1;false]);
                        p = find(tSearch==1);
                        q = find(tSearch==-1);
                        [maxlen,ix] = max(q-p);
                        firstSearch = p(ix);
                        lastSearch = q(ix)-1;
                        
                        CCEPmed = median(extractedSigs(:,klabel==i),2);
                        [minval,inx] = min(CCEPmed);
                        % account for case if it's at inx = 1
                        if inx == 1
                            inx = inx +1;
                        end
                        CCEPmag = (CCEPmed(inx)+CCEPmed(inx-1)+CCEPmed(inx+1))/3;
                        CCEPbyNumStim{i} = CCEPmed;
                    end
                end
                %%
                %                 if anova < 0.05
                figure
                set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
                subplot(3,1,1);
                
                % original
                prettyline(1e3*t,1e6*awins(:, keeps), label(keeps), colors);
                %
                %                 % try subtracting mean of baselines, DJC 2-4-2016, post
                %                 % convo with miah
                %xlim(1e3*[-0.025 max(t)]);
                
                xlim(1e3*[min(t) max(t)]);
                yl = ylim;
                yl(1) = min(-10, max(yl(1),-140));
                yl(2) = max(10, min(yl(2),100));
                ylim(yl);
                highlight(gca, [0 t(ct)*1e3], [], [.5 .5 .5]) %this is the part that plots that stim window
                vline(0);
                xlabel('time (ms)');
                ylabel('ECoG (uV)');
                %                 title(sprintf('EP By N_{CT}: %s, %d, {%s}', sid, chan, suffix{typei}))
                title(sprintf('%s CCEPs for Channel %d stimuli in {%s}',sid,chan,suffix{typei}))
                leg = {'Pre'};
                for d = 1:length(labelGroupStarts)
                    if d == length(labelGroupStarts)
                        leg{end+1} = sprintf('%d<=CT', labelGroupStarts(d));
                    else
                        leg{end+1} = sprintf('%d<=CT<%d', labelGroupStarts(d), labelGroupEnds(d));
                    end
                end
                leg{end+1} = 'Stim Window';
                %     leg{end+1} = 'EP_P';
                legend(leg, 'location', 'Southeast')
                
                %
                % try zscore?
                %                                 prettyline(1e3*t((1e3*t)>10), zscore(1e6*awins((1e3*t)>10, keeps)), label(keeps), colors);
                %     ylim([-130 50]);
                
                % second mean subtracted
                
                subplot(3,1,2)
                prettyline(1e3*t, bsxfun(@minus,1e6*awins(:, keeps),1e6*median(awins(:,baselines),2)), label(keeps), colors);
                
                
                % changed DJC 1-7-2016
                % xlim(1e3*[-0.025 max(t)]);
                
                xlim(1e3*[min(t) max(t)]);
                %                 xlim([-5 300]);
                %     vline([6 20 40], 'k');
                %     highlight(gca, [25 33], [], [.6 .6 .6])
                %             highlight(gca, [0 4], [], [.3 .3 .3]);
                %             vline(0.030*1e3);
                %             vline(0.080*1e3);
                yl = ylim;
                yl(1) = min(-10, max(yl(1),-140));
                yl(2) = max(10, min(yl(2),100));
                ylim(yl);
                highlight(gca, [0 t(ct)*1e3], [], [.5 .5 .5]) %this is the part that plots that stim window
                vline(0);
                %                 vline(80);
                
                % DJC - 2-11-2016 - set y limits for z-score
                %                 ylim([-2 2])
                
                xlabel('time (ms)');
                ylabel('ECoG (uV)');
                title('Median Subtracted')
                
                title(sprintf('EP By N_{CT}: %s, %d, {%s}', sid, chan, suffix{typei}))
                title(sprintf('%s CCEPs for Channel %d stimuli in {%s}',sid,chan,suffix{typei}))
                leg = {'Pre'};
                for d = 1:length(labelGroupStarts)
                    if d == length(labelGroupStarts)
                        leg{end+1} = sprintf('%d<=CT', labelGroupStarts(d));
                    else
                        leg{end+1} = sprintf('%d<=CT<%d', labelGroupStarts(d), labelGroupEnds(d));
                    end
                end
                leg{end+1} = 'Stim Window';
                %     leg{end+1} = 'EP_P';
                legend(leg, 'location', 'Southeast')
                
                
                %% added DJC 2-11-2016 to try and do quick stats
                % start with negative surface deflection 10 -> 30
                
                
                %                 figure
                subplot(3,1,3)
                prettybar(a1, label(keeps), colors, gcf);
                set(gca, 'xtick', []);
                ylabel('\DeltaEP_N (uV)');
                
                title(sprintf('Change in EP_N by N_{CT}: One-Way Anova F=%4.2f p=%0.4f', table{2,5}, table{2,6}));
                figure
                [pCond,tblCond,statsCond] = kruskalwallis(a1',label(keeps));
                %
                % %                     SaveFig(OUTPUT_DIR, sprintf(['epSTATS-%s-%dUNFILT' suffix{typei}], sid, chan), 'eps', '-r600');
                % %                     SaveFig(OUTPUT_DIR, sprintf(['epSTATS-%s-%dUNFILT' suffix{typei}], sid, chan), 'png', '-r600');
                %                  end
                
            end
            
            %             shuffleChans{chan}{typei} = {CI_lo CI_hi sgc CCEPbyNumStim};
            
            %             %% TFA - 2-24-2016, trying this
            %
            %             for i = 1:length(ulabels)-1
            %                 fs = efs;
            %                 fw = [1:3:200];
            %                 extractedSigs = 1e6*(kwins);
            %                 extractedSigsBase = extractedSigs(t>0.005,label(keeps)==0);
            %                 extractedSigsTest = extractedSigs(t>0.01,label(keeps)==i);
            %                 extractedSigsPre = extractedSigs(t<-0.005, label(keeps)==i);
            %                 [C, ~, ~, ~] = time_frequency_wavelet(extractedSigsTest, fw, fs, 1, 1, 'CPUtest');
            %                 [Cbase, ~, ~, ~] = time_frequency_wavelet(extractedSigsPre, fw, fs, 1, 1, 'CPUtest');
            %
            %                 normC=normalize_plv(C',Cbase');
            %                 figure
            %                 subplot(2,1,1)
            %                 plot(t(t>0.01),extractedSigsTest,t(t>0.01),mean(extractedSigsTest,2),'k','linewidth',[4])
            %                 colorbar
            %                 subplot(2,1,2)
            %                 imagesc(t(t>0.01),fw,normC);
            %                 axis xy;
            %                 colorbar;
            %                 colormap(jet)
            %                             set_colormap_threshold(gcf, [0 2], [0 10], [1 1 1]);   % changed to [-1 1] DJC 7/2014
            %                 %             title(trodeNameFromMontage(interesting(chanIdx),Montage));
            %                 %
            %             end
            
        end
        
        
    end
    %     save(fullfile(OUTPUT_DIR, [sid 'epSTATSsig.mat']), 'sigChans','CCEPbyNumStim','dataForAnova','ZscoredDataForAnova');
    %close all; clearvars -except idx SIDS OUTPUT_DIR META_DIR SUB_DIR
    %     save(fullfile(OUTPUT_DIR, [sid 'epSTATSsigShuffle.mat']), 'shuffleChans');
end
