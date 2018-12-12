%% Constants
%close all; clear all;

Z_Constants
SUB_DIR = fullfile(myGetenv('subject_dir'));
% OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'));

%% additional options

savePlot = 0;
saveIt = 0;
plotIt = 1;
plotItTrials = 0;
%%
for idx = 6:6
    sid = SIDS{idx};
    
    switch(sid)
        case '8adc5c'
            tp = strcat(SUB_DIR,'\8adc5c\data\D6\8adc5c_BetaTriggeredStim');
            block = 'Block-67';
            stims = [31 32];
            chans = [8 7 48];
            
        case 'd5cd55'
            tp = strcat(SUB_DIR,'\d5cd55\data\D8\d5cd55_BetaTriggeredStim');
            block = 'Block-49';
            stims = [54 62];
            chans = [53 61 63];
            
            goods = sort([44 45 46 52 53 55 60 61 63]);
            betaChan = 53;
            bads = [1 49 58 59];
            
            % have to set t_min and t_max for each subject
            %t_min = 0.004833;
            % t_min of 0.005 would find the really early ones
            t_min = 0.006;
            t_max = 0.06;
            
        case 'c91479'
            tp = strcat(SUB_DIR,'\c91479\data\d7\c91479_BetaTriggeredStim');
            block = 'BetaPhase-14';
            stims = [55 56];
            chans = [64 63 48];
            betaChan = 64;
            goods = sort([ 39 40 47 48 63 64]);
            bads = [1 2 3 31 57];
            
            t_min = 0.003;
            t_max = 0.033;
        case '7dbdec'
            tp = strcat(SUB_DIR,'\7dbdec\data\d7\7dbdec_BetaTriggeredStim');
            block = 'BetaPhase-17';
            stims = [11 12];
            chans = [4 5 14];
            goods = sort([4 5 10 13]);
            betaChan = 4;
            t_min = 0.007;
            t_max = 0.048;
            bads = [8 57];
            
        case '9ab7ab'
            tp = strcat(SUB_DIR,'\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim');
            block = 'BetaPhase-3';
            stims = [59 60];
            chans = [51 52 53 58 57];
            % chans = 29;
            betaChan = 51;
            
            goods = sort([42 43 49 50 51 52 53 57 58]);
            t_min = 0.006;
            t_max = 0.06;
            bads = [1 9 10 35 43];
            
        case '702d24'
            tp = strcat(SUB_DIR,'\702d24\data\d7\702d24_BetaStim');
            block = 'BetaPhase-4';
            stims = [13 14];
            chans = [4 5 21];
            goods = [ 5 ];
            t_min = 0.008;
            t_max = 0.046;
            bads = [23 27 28 29 30 32 44 52 60];
            
            
        case 'ecb43e' % added DJC 7-23-2015
            tp = strcat(SUB_DIR,'\ecb43e\data\d7\BetaStim');
            block = 'BetaPhase-3';
            stims = [56 64];
            chans = [47 55];
            betaChan = 55;
            goods = sort([55 63 54 47 48]);
            bads = [57:64];
            
            t_min = 0.008;
            t_max = 0.06;
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
            
            goods = [ 14 21 23];
            bads = [24 25 29];
            t_min = 0.005;
            t_max = 0.075;
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
            bads = [24 25 29];
            t_min = 0.005;
            t_max = 0.075;
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
    
    % set statistical threshold
    statThresh = length(chans);
    chans = [29 36 37 38 46];
    chans = [5];
    for chan = chans
        
        %% load in ecog data for that channel
        fprintf('loading in ecog data for %s:\n',sid);
        fprintf('channel %d:\n',chan);
        
        tic;
        grp = floor((chan-1)/16);
        ev = sprintf('ECO%d', grp+1);
        achan = chan - grp*16;
        [eco, info] = tank.readWaveEvent(ev, achan);
        efs = info.SamplingRateHz;
        eco = 4*eco';
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
        
        if strcmp(sid,'ecb43e')
            for sti = 1:length(sts)
                win = (sts(sti)-presamps):(sts(sti)+postsamps+1);
                
                %           interpolation approach
                eco(win(presamps:(ct-1))) = interp1([presamps-1 ct], eco(win([presamps-1 ct])), presamps:(ct-1));
            end
            
            eco = toRow(notch(eco, [60 120 180 240], efs, 2, 'causal'));
        end
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
        
        presamps = round(0.100*efs);
        postsamps = round(0.120*efs);
        
        ptis = round(stims(2,pts)/fac);
        
        t = (-presamps:postsamps)/efs;
        
        index = find(t==0);
        ct = index + ct - round(0.025*efs);
        
        wins = squeeze(getEpochSignal(eco', ptis-presamps, ptis+postsamps+1));
        awins = wins-repmat(mean(wins(t<-0.005,:),1), [size(wins, 1), 1]);
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
            
            probes = pstims(5,:) < .250*fs & bursts(5,pstims(4,:))==types(typei);
            
            if (sum(probes) < 100)
                warning('N probes = %d.', sum(probes));
            end
            
            label = bursts(4,pstims(4,:));
            label(baselines) = 0;
            
            if (types(typei) == nullType)
                
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
            %
            %             tMin = t_min;
            %             tMax = t_max;
            %
            %             a1 = 1e6*max(abs((awins(t>tMin & t < tMax,keeps))));
            %             a1Median = median(a1);
            %             a1 = a1 - median(a1(label(keeps)==0));
            %
            %             a = 1e6*max(abs((awins(t>tMin & t < tMax,keeps))));
            %             dataForAnova{chan}{typei} = {a label keeps};
            %
            %             [anovaNull,tableNull,statsNull] = anova1(a1', label(keeps), 'on');
            %             [c,m,h,gnames] = multcompare(statsNull,'display','on');
            %             sigChans{chan}{typei} = {m c a1Median a1 label keeps};
            %
            %% peak to peak values
            tBegin = 0.01;
            tEnd = 0.06;
            
            tBegin = t_min;
            tEnd = t_max;
            smooth = 1;
            [signalPP,pkLocs,trLocs] =  extract_PP_betaStim(awins,t,tBegin,tEnd,smooth);
            
            dataForPPanalysis{chan}{typei} = {signalPP pkLocs trLocs label keeps};
            %%
            
            [kruskalWallisResult,table,stats] = kruskalwallis(signalPP(keeps), label(keeps), 'off');
            if kruskalWallisResult < 0.05/statThresh
                figure
                [c,m,h,gnames] = multcompare(stats,'display','on');
            end
            
            kruskalWallisStats{chan}{typei} = {kruskalWallisResult table stats};
            %% zscore
            plotItTrials = 0;
            %             for i = 1:length(ulabels)-1
            %                 total = 1e6*(awins(:,keeps));
            %                 base = 1e6*(awins(:,label==0 & keeps));
            %                 test = 1e6*(awins(:,label==i & keeps));
            %                 %[zT,magT,latT] = zscoreCCEP(total,test,t,tMin,tMax);
            %                 [zT,magT,latT] = zscoreWithFindPeaks(total,test,t,tMin,tMax,plotItTrials);
            %                 %[zB,magB,latB] = zscoreCCEP(total,base,t,tMin,tMax);
            %                 [zB,magB,latB] = zscoreWithFindPeaks(total,test,t,tMin,tMax,plotItTrials);
            %                 CCEPbyNumStim{chan}{typei}{i} = {zT magT latT zB magB latB};
            %             end
            %
            %             % zscore INDIVIDUAL FOR ANOVA 4-7-2016 DJC
            %             total = 1e6*(awins(:,keeps));
            %             %[~,~,~,zI,magI,latencyIms] = zscoreCCEP(total,total,t,tMin,tMax);
            %             [~,~,~,~,~,zI,magI,latencyIms,~,~] = zscoreWithFindPeaks(total,test,t,tMin,tMax,plotItTrials);
            
            shuffleSig = 0;
            if shuffleSig
                % need to do for each type
                CCEPbyNumStim = {};
                for i = 1:length(ulabels)-1
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
            
            if plotIt
                %
             %  if kruskalWallisResult < 0.05/statThresh
                    %%
                    figure
                    % this sets the figure to be the whole screen
                    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
                    subplot(3,1,1);
                    
                    % original
                    prettyline(1e3*t,1e6*awins(:, keeps), label(keeps), colors);
                    % xlim(1e3*[-0.025 max(t)]);
                    
                    xlim(1e3*[min(t) max(t)]);
                    yl = ylim;
                    yl(1) = min(-10, max(yl(1),-140*4));
                    yl(2) = max(10, min(yl(2),100*4));
                    
                     yl(1) = min(-10, max(yl(1),-340*4));
                    yl(2) = max(10, min(yl(2),300*4));
                    
                    ylim(yl);
                    highlight(gca, [0 t(ct)*1e3], [], [.5 .5 .5]) %this is the part that plots that stim window
                    vline(0);
                    xlabel('time (ms)');
                    ylabel('ECoG (uV)');
                    %                 title(sprintf('EP By N_{CT}: %s, %d, {%s}', sid, chan, suffix{typei}))
                    if (types(typei) == nullType)
                        title(sprintf('%s CCEPs for Channel %d, Null Condition',sid,chan))
                        leg = {'Pre','Post'};
                    elseif             (types(typei) ~= nullType)
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
                    
                    subplot(3,1,2)
                    
                    prettyline(1e3*t, bsxfun(@minus,1e6*awins(:, keeps),1e6*median(awins(:,baselines),2)), label(keeps), colors);
                    
                    xlim(1e3*[min(t) max(t)]);
                    
                    yl = ylim;
                    yl(1) = min(-10, max(yl(1),-140*4));
                    yl(2) = max(10, min(yl(2),100*4));
                    ylim(yl);
                    
                    highlight(gca, [0 t(ct)*1e3], [], [.5 .5 .5])
                    vline(0);
                    
                    xlabel('time (ms)');
                    ylabel('ECoG (uV)');
                    title('Median Subtracted')
                    
                    if (types(typei) == nullType)
                        title(sprintf('%s CCEPs for Channel %d, Null Condition',sid,chan))
                        leg = {'Pre','Post'};
                    else (types(typei) ~= nullType)
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
                        legend(leg, 'location', 'Southeast')
                        
                    end
                    
                    subplot(3,1,3)
                    prettybar(signalPP(keeps), label(keeps), colors, gcf);
                    set(gca, 'xtick', []);
                    ylabel('\DeltaEP_N (uV)');
                    
                    title(sprintf('Change in EP_N by N_{CT}: Kruskal-Wallis test F=%4.2f p=%0.4f', table{2,5}, table{2,6}));
                    
                    if savePlot
                        %     SaveFig(OUTPUT_DIR, sprintf(['EP-phase-%d-sid-%s-chan-%d'],typei,sid, chan,type,signalType), 'svg');
                        SaveFig(OUTPUT_DIR, sprintf(['EP-phase-%d-sid-%s-chan-%d'],typei,sid, chan), 'png','-r600');
                    end
               % end
            end
        end
        
        
    end
    if saveIt
        save(fullfile(OUTPUT_DIR, [sid 'epSTATS-PP-sig.mat']), 'dataForPPanalysis','kruskalWallisStats');
        %close all;
        fprintf('saved %s:\n',sid);
        
        clearvars -except idx SIDS OUTPUT_DIR META_DIR SUB_DIR savePlot saveIt plotIt plotItTrials
        
    end
end





