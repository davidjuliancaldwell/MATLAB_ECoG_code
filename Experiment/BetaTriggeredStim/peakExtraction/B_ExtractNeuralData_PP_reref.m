%% constants
close all; clear all;clc
%clear all
%% parameters

Z_Constants
SUB_DIR = fullfile(myGetenv('subject_dir'));

%% additional options

savePlot = 0;
saveIt = 1;
plotIt = 0;
plotItTrials = 0;
plotItStimArtifact = 0;
chanInt = 31;
labelChoice = 0;
shuffleSig = 0;
avgTrials = 0;
numAvg = 3;
smoothPP = 1;
shuffleSigPP = 0;
rerefMode = 'median';

%%
for idx = 4:4
    sid = SIDS{idx};
    
    switch(sid)
        
        case 'd5cd55'
            block = 'Block-49';
            tp = strcat(SUB_DIR,'\d5cd55\data\D8\d5cd55_BetaTriggeredStim');
            
            stims = [54 62];
            chans = [53 61 63];
            
            rerefChans = [2:40];
            goods = sort([44 45 46 52 53 55 60 61 63]);
            betaChan = 53;
            bads = [1 49 58 59];
            
            % have to set t_min and t_max for each subject
            %t_min = 0.004833;
            % t_min of 0.005 would find the really early ones
            t_min = 0.006;
            t_max = 0.06;
            
        case 'c91479'
            block = 'BetaPhase-14';
            tp = strcat(SUB_DIR,'\c91479\data\d7\c91479_BetaTriggeredStim');
            
            stims = [55 56];
            chans = [64 63 48];
            betaChan = 64;
            goods = sort([ 39 40 47 48 63 64]);
            bads = [1 2 3 31 57];
            rerefChans = [4:29 32:37 41:45 49:52 57:61 ];
            
            t_min = 0.005;
            t_max = 0.036;
        case '7dbdec'
            block = 'BetaPhase-17';
            rerefChans = [1:3 7 15 1:16 17:19 22:24 33:56 58:64];
            tp = strcat(SUB_DIR,'\7dbdec\data\d7\7dbdec_BetaTriggeredStim');
            
            stims = [11 12];
            chans = [4 5 14];
            goods = sort([4 5 10 13]);
            betaChan = 4;
            t_min = 0.007;
            t_max = 0.048;
            bads = [8 57];
            
        case '9ab7ab'
            block = 'BetaPhase-3';
            tp = strcat(SUB_DIR,'\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim');
            
            stims = [59 60];
            chans = [51 52 53 58 57];
            % chans = 29;
            betaChan = 51;
            rerefChans = [2:8 10:40 45:48 54:56];
            
            goods = sort([42 43 49 50 51 52 53 57 58]);
            t_min = 0.006;
            t_max = 0.06;
            bads = [1 9 10 35 43];
            
        case '702d24'
            block = 'BetaPhase-4';
            rerefChans = [1:4 6:12 15:22 24 25:27 33:40 41:43 45:51 53:58 62:64];
            tp = strcat(SUB_DIR,'\702d24\data\d7\702d24_BetaStim');
            betaChan = 5;
            stims = [13 14];
            chans = [4 5 21];
            goods = [ 5 ];
            t_min = 0.008;
            t_max = 0.046;
            bads = [23 27 28 29 30 32 44 52 60];
            
            
        case 'ecb43e' % added DJC 7-23-2015
            block = 'BetaPhase-3';
            rerefChans = [1:40 41:44 49:52];
            tp = strcat(SUB_DIR,'\ecb43e\data\d7\BetaStim');
            
            stims = [56 64];
            chans = [47 55];
            betaChan = 55;
            goods = sort([55 63 54 47 48]);
            bads = [57:64];
            
            t_min = 0.006;
            t_max = 0.06;
        case '0b5a2e' % added DJC 7-23-2015
            tp = strcat(SUB_DIR,'\0b5a2e\data\d8\0b5a2e_BetaStim\0b5a2e_BetaStim');
            
            block = 'BetaPhase-2';
            rerefChans = [1:8 9:12 17:20 24 25:28 33:37 38 41:48 49:64];
            
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
            
            goods = [ 14 21 23];
            bads = [24 25 29];
            t_min = 0.005;
            t_max = 0.06;
        case '0b5a2ePlayback' % added DJC 7-23-2015
            tp = strcat(SUB_DIR,'\0b5a2e\data\d8\0b5a2e_BetaStim\0b5a2e_BetaStim');
            
            block = 'BetaPhase-4';
            rerefChans = [1:8 9:12 17:20 24 25:28 33:37 38 41:48 49:64];
            
            stims = [22 30];
            %             chans = [23 31 21 14 15 32 40];
            %             chans = [23 31];
            %             chans = 23;
            chans = [1:64];
            %             chans = 40;
            betaChan = 31;
            goods = sort([12 13 14 15 16 21 23 31 32 39 40]);
            bads = [24 25 29];
            t_min = 0.005;
            t_max = 0.06;
        otherwise
            error('unknown SID entered');
    end
    
    badsTotal = [stims bads];
    
    chans = [1:64];
    chans(ismember(chans, badsTotal)) = [];
    %% load in the trigger data
    
    tank = TTank;
    tank.openTank(tp);
    tank.selectBlock(block);
    
    if strcmp(sid,'0b5a2ePlayback')
        load(fullfile(META_DIR, ['0b5a2e' '_tables_modDJC.mat']), 'bursts', 'fs', 'stims');
        delay = 577869;
    elseif strcmp(sid,'0b5a2e')
        load(fullfile(META_DIR, [sid '_tables_modDJC.mat']), 'bursts', 'fs', 'stims');
    else
        load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts', 'fs', 'stims');
        
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
    delayDelivery = 14;
    
    % add 14 samples to approximately account for the delay between the
    % stimulation trigger command and actual registration
    stims(2,:) = stims(2,:) + delayDelivery;
    bursts(2,:) = bursts(2,:) + delayDelivery;
    bursts(3,:) = bursts(3,:) + delayDelivery;
    
    %figure
    %% process each ecog channel individually
    
    sigChans = {};
    shuffleChans = {};
    CCEPbyNumStim = {};
    
    dataForAnova = {};
    
    ZscoredDataForAnova = {};
    
    %% do referencing on list of channels
    
    for chan = rerefChans
        
        %% load in ecog data for that channel
        fprintf('loading in ecog data for:%s \n',sid);
        fprintf('channel %d:\n',chan);
        
        tic;
        grp = floor((chan-1)/16);
        ev = sprintf('ECO%d', grp+1);
        achan = chan - grp*16;
        
        %         [eco, efs] = tdt_loadStream(tp, block, ev, achan);
        [eco, info] = tank.readWaveEvent(ev, achan);
        efs = info.SamplingRateHz;
        eco = 4*eco';
        
        toc;
        
        fac = fs/efs;
        
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
        
        presamps = round(0.100*efs);
        postsamps = round(0.120*efs);
        
        ptis = round(stims(2,pts)/fac);
        
        t = (-presamps:postsamps)/efs;
        
        
        wins = squeeze(getEpochSignal(eco', ptis-presamps, ptis+postsamps+1));
        winsReref(:,:,chan) = wins;
    end
    
    switch(rerefMode)
        case 'mean'
            rerefQuant = mean(winsReref,3);
            
        case 'median'
            rerefQuant = median(winsReref,3);
    end
    
    %% now do peak to peak
    % set statistical threshold
    statThresh = length(chans);
    
    for chan = chans
        %% load in ecog data for that channel
        fprintf('loading in ecog data for: %s \n',sid);
        fprintf('channel %d:\n',chan);
        
        tic;
        grp = floor((chan-1)/16);
        ev = sprintf('ECO%d', grp+1);
        achan = chan - grp*16;
        
        %         [eco, efs] = tdt_loadStream(tp, block, ev, achan);
        [eco, info] = tank.readWaveEvent(ev, achan);
        efs = info.SamplingRateHz;
        eco = 4*eco';
        
        toc;
        
        fac = fs/efs;
        
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
            
        else
            error 'unknown sid';
        end
        
        presamps = round(0.100*efs);
        postsamps = round(0.120*efs);
        
        ptis = round(stims(2,pts)/fac);
        
        t = (-presamps:postsamps)/efs;
        
        wins = squeeze(getEpochSignal(eco', ptis-presamps, ptis+postsamps+1));
        wins = wins - rerefQuant;
        pstims = stims(:,pts);
        
        % considered a baseline if it's been at least N seconds since the last
        % burst ended
        
        baselines = pstims(5,:) > 2 * fs;
        
        if (sum(baselines) < 100)
            warning('N baselines = %d.', sum(baselines));
        end
        
        types = unique(bursts(5,pstims(4,:)));
        
        %DJC - modify suffix to list conditioning type
        suffix = arrayfun(@(x) num2str(x), types, 'uniformoutput', false);
        %
        suffix = cell(1,4);
        suffix{1} = 'Phase 1';
        suffix{2} = 'Phase 2';
        suffix{3} = 'null condition';
        suffix{4} = 'Phase 3';
        
        nullType = 2;
        
        for typei = 1:length(types)
            awins = wins-repmat(mean(wins(t<-0.005 & t>-0.1,:),1), [size(wins, 1), 1]);
            
            probes = pstims(5,:) < .5*fs & bursts(5,pstims(4,:))==types(typei);
            
            if (sum(probes) < 100)
                warning('N probes = %d.', sum(probes));
            end
            
            
            if (types(typei) == nullType)
                label = nan(1,length(bursts(4,pstims(4,:))));
                label(baselines) = 0;
                label(probes) = 1 ;
                
            elseif (types(typei) ~= nullType)
                label = bursts(4,pstims(4,:));
                label(baselines) = 0;
                labelGroupStarts = [1 3 5];
                labelGroupEnds   = [labelGroupStarts(2:end) Inf];
                
                for gIdx = 1:length(labelGroupStarts)
                    labeli = label >= labelGroupStarts(gIdx) & label < labelGroupEnds(gIdx);
                    label(labeli) = gIdx;
                end
                
            end
            
            keeps = probes | baselines;
            load('line_colormap.mat');
            
            kwins = awins(:, keeps);
            klabel = label(keeps);
            ulabels = unique(klabel);
            colors = cm(round(linspace(1, size(cm, 1), length(ulabels))), :);
            
            tBegin = t_min;
            tEnd = t_max;
            if avgTrials
                awinsNew = [];
                labelNew = [];
                keepsNew = [];
                for i = 1:length(ulabels)
                    awinsInt = awins(:,label == ulabels(i) & keeps);
                    [awinsAvg] = avg_every_p_elems(awinsInt,numAvg);
                    awinsNew = [awinsNew awinsAvg];
                    labelSpecific = repmat(ulabels(i),size(awinsAvg,2),1);
                    keepsSpecific = repmat(1,size(awinsAvg,2),1);
                    keepsNew = [keepsNew; keepsSpecific];
                    labelNew = [labelNew; labelSpecific];
                end
                
                label = labelNew;
                keeps = logical(keepsNew);
                awins = awinsNew;
                klabel = label;
            end
            %%
            
            if plotItStimArtifact && chan == chanInt
                plot_stimArtifact_CEPs(t,kwins,klabel,labelChoice);
            end
            %%
            
            [signalPP,pkLocs,trLocs] =  extract_PP_betaStim(awins,t,tBegin,tEnd,smoothPP);
            
            dataForPPanalysis{chan}{typei} = {signalPP pkLocs trLocs label keeps};
            
            if shuffleSigPP
                % need to do for each type
                CCEPbyNumStim = {};
                for i = 1:length(ulabels)-1
                    
                    extractedSigsBase = signalPP(label==0 & keeps);
                    extractedSigsTest = signalPP(label==i & keeps);
                    extractedSigsPlot = [extractedSigsBase extractedSigsTest];
                    extractedSigsLabel = [zeros(size(extractedSigsBase)) ones(size(extractedSigsTest))];
                    figure
                    prettybox(extractedSigsPlot,extractedSigsLabel,colors,2,1);
                    [p, observeddifference, effectsize] =  permutationTest(extractedSigsTest,extractedSigsBase,1000,'plot',1);
                    effectSize = mes(extractedSigsTest',extractedSigsBase','hedgesg','nBoot',1000);
                    shuffleChansPP{chan}{typei} = {p, observeddifference, effectsize};
                end
            end
            %%
            
            [kruskalWallisResult,table,stats] = kruskalwallis(signalPP(keeps), label(keeps), 'off');
            if kruskalWallisResult < 0.05/statThresh && plotIt
                figure
                [c,m,h,gnames] = multcompare(stats,'display','on');
            end
            
            kruskalWallisStats{chan}{typei} = {kruskalWallisResult table stats};
            
            if shuffleSig
                % need to do for each type
                CCEPbyNumStim = {};
                for i = 1:length(ulabels)-1
                    t_minS = tBegin;
                    t_maxS = tEnd;
                    Nperm = 1000;
                    sp = 95;
                    extractedSigs = 1e6*((awins(t>t_minS & t<t_maxS,:)));
                    extractedSigsBase = extractedSigs(:,label==0 & keeps);
                    extractedSigsTest = extractedSigs(:,label==i & keeps);
                    
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
                    % account for case where inx = 1 to avoid addressing matrix
                    % outside of bounds
                    if inx == 1
                        inx = inx + 1;
                    end
                    CCEPmag = (CCEPmed(inx)+CCEPmed(inx-1)+CCEPmed(inx+1))/3;
                    CCEPbyNumStim{i} = CCEPmag;
                    shuffleChans{chan}{typei} = {CI_lo CI_hi sgc CCEPbyNumStim};
                end
            end
            
            if plotIt && any(chan==goods)
                %
                %  if kruskalWallisResult < 0.05/statThresh
                %%
                figure
                % this sets the figure to be the whole screen
                set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
                subplot(3,1,1);
                
                prettyline(1e3*t,1e6*awins(:, keeps), label(keeps), colors);
                xlim(1e3*[min(t) max(t)]);
                yl = ylim;
                yl(1) = min(-10, max(yl(1),-140*4));
                yl(2) = max(10, min(yl(2),100*4));
                
                yl(1) = min(-10, max(yl(1),-340*4));
                yl(2) = max(10, min(yl(2),300*4));
                
                ylim(yl);
                
                xlim([-10 60])
                ylim([-500 500])
                
                %  vline(1e3*7/efs);
                vline(0);
                xlabel('time (ms)');
                ylabel('ECoG (uV)');
                %                 title(sprintf('EP By N_{CT}: %s, %d, {%s}', sid, chan, suffix{typei}))
                if (types(typei) == nullType)
                    title(sprintf('%s CEPs for Channel %d, Null Condition',sid,chan))
                    leg = {'Pre','Post'};
                elseif (types(typei) ~= nullType)
                    title(sprintf('EP By N_{CT}: %s, %d, {%s}', sid, chan, suffix{typei}))
                    title(sprintf('%s CEPs for Channel %d stimuli in {%s}',sid,chan,suffix{typei}))
                    leg = {'Pre'};
                    for d = 1:length(labelGroupStarts)
                        if d == length(labelGroupStarts)
                            leg{end+1} = sprintf('%d<=CT', labelGroupStarts(d));
                        else
                            leg{end+1} = sprintf('%d<=CT<%d', labelGroupStarts(d), labelGroupEnds(d));
                        end
                    end
                end
                
                leg{end+1} = 'Stim Window';
                legend(leg, 'location', 'Southeast')
                set(gca,'fontsize',18)
                subplot(3,1,2)
                
                prettyline(1e3*t, bsxfun(@minus,1e6*awins(:, keeps),1e6*median(awins(:,label == 0 & keeps),2)), label(keeps), colors);
                
                xlim(1e3*[min(t) max(t)]);
                
                yl = ylim;
                yl(1) = min(-10, max(yl(1),-140*4));
                yl(2) = max(10, min(yl(2),100*4));
                ylim(yl);
                
                xlim([-10 60])
                ylim([-500 500])
                
                %                 highlight(gca, [0 t(ct)*1e3], [], [.5 .5 .5])
                vline(0);
                
                xlabel('time (ms)');
                ylabel('ECoG (uV)');
                title('CEP Median Subtracted')
                
                if (types(typei) == nullType)
                    %                     title(sprintf('%s CCEPs for Channel %d, Null Condition',sid,chan))
                    leg = {'Pre','Post'};
                elseif (types(typei) ~= nullType)
                    %                     title(sprintf('EP By N_{CT}: %s, %d, {%s}', sid, chan, suffix{typei}))
                    %                     title(sprintf('%s CCEPs for Channel %d stimuli in {%s}',sid,chan,suffix{typei}))
                    leg = {'Pre'};
                    for d = 1:length(labelGroupStarts)
                        if d == length(labelGroupStarts)
                            leg{end+1} = sprintf('%d<=CT', labelGroupStarts(d));
                        else
                            leg{end+1} = sprintf('%d<=CT<%d', labelGroupStarts(d), labelGroupEnds(d));
                        end
                    end
                    %                     leg{end+1} = 'Stim Window';
                    %                     legend(leg, 'location', 'Southeast')
                    
                end
                set(gca,'fontsize',18)
                
                subplot(3,1,3)
                prettybar(1e6*signalPP(keeps), label(keeps), colors, gcf);
                set(gca, 'xtick', []);
                ylabel('Magntiude of CEP_N (uV)');
                
                title(sprintf('Magnitude of CEP_N by N_{CT}: Kruskal-Wallis test F=%4.2f p=%0.4f', table{2,5}, table{2,6}));
                set(gca,'fontsize',18)
                
                if savePlot
                    %     SaveFig(OUTPUT_DIR, sprintf(['EP-phase-%d-sid-%s-chan-%d'],typei,sid, chan,type,signalType), 'svg');
                    SaveFig(OUTPUT_DIR, sprintf(['EP-phase-%d-sid-%s-chan-%d'],typei,sid, chan), 'png','-r600');
                end
                % end
            end
        end
        
    end
    if saveIt
        save(fullfile(OUTPUT_DIR, [sid 'epSTATS-PP-sig-reref-100.mat']), 'dataForPPanalysis','kruskalWallisStats');
        %close all;
        fprintf('saved %s:\n',sid);
        
        clearvars -except idx SIDS OUTPUT_DIR META_DIR SUB_DIR savePlot saveIt plotIt plotItTrials rerefMode plotItStimArtifact chanInt labelChoice shuffleSig avgTrials numAvg smoothPP shuffleSigPP
    end
end





