%% Constants
Z_Constants;
addpath ./scripts;

%% parameters

% need to be fixed to be nonspecific to subject
% SIDS = SIDS(2:end);
SIDS = SIDS(2);
    
for idx = 1:length(SIDS)
    sid = SIDS{idx};
    
    switch(sid)
        case '8adc5c'
            % sid = SIDS{1};
            tp = 'd:\research\subjects\8adc5c\data\d6\8adc5c_BetaTriggeredStim';
            block = 'Block-67';
            stims = [31 32];
            chans = [8 7 48];
        case 'd5cd55'
            % sid = SIDS{2};
            tp = 'd:\research\subjects\d5cd55\data\d8\d5cd55_BetaTriggeredStim';
            block = 'Block-49';
            stims = [54 62];
            chans = [53 61 63];
        case 'c91479'
            % sid = SIDS{3};
            tp = 'd:\research\subjects\c91479\data\d7\c91479_BetaTriggeredStim';
            block = 'BetaPhase-14';
            stims = [55 56];
            chans = [64 63 48];
        case '7dbdec'
            % sid = SIDS{4};
            tp = 'd:\research\subjects\7dbdec\data\d7\7dbdec_BetaTriggeredStim';
            block = 'BetaPhase-17';
            stims = [11 12];
            chans = [4 5 14];
        case '9ab7ab'
%             sid = SIDS{5};
            tp = 'd:\research\subjects\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim';
            block = 'BetaPhase-3';
            stims = [59 60];
            chans = [51 52 53 58 57];
% chans = 29;
        case '702d24'
            tp = 'd:\research\subjects\702d24\data\d7\702d24_BetaStim';
            block = 'BetaPhase-4';
            stims = [13 14];
            chans = [4 5 21];
        otherwise
            error('unknown SID entered');
    end
    
    chans(ismember(chans, stims)) = [];

    %% load in the trigger data
    load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts', 'fs', 'stims');

    % drop any stims that happen in the first 500 milliseconds
    stims(:,stims(2,:) < fs/2) = [];

    % drop any probe stimuli without a corresponding pre-burst/post-burst
    bads = stims(3,:) == 0 & (isnan(stims(4,:)) | isnan(stims(6,:)));
    stims(:, bads) = [];

    tank = TTank;
    tank.openTank(tp);
    tank.selectBlock(block);
    
    %% process each ecog channel individually
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
% % %         eco = notch(eco, [60], efs, 2, 'causal');
% %         

            %% preprocess eco    
%             presamps = round(0.050 * efs); % pre time in sec
            presamps = round(0.025 * efs); % pre time in sec
            postsamps = round(0.120 * efs); % post time in sec

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

            subplot(8,8,chan);
            plot(foo);
            vline(ct);
            
            for sti = 1:length(sts)
                win = (sts(sti)-presamps):(sts(sti)+postsamps+1);

                % interpolation approach
                eco(win(presamps:(ct-1))) = interp1([presamps-1 ct], eco(win([presamps-1 ct])), presamps:(ct-1));            
            end

%             eco = bandpass(eco, 1, 40, efs, 4, 'causal');
%             eco = notch(eco, 60, efs, 2, 'causal');
    
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
        else
            error 'unknown sid'; 
        end

        ptis = round(stims(2,pts)/fac);

        t = (-presamps:postsamps)/efs;

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

        if (sum(baselines) < 100)
            warning('N baselines = %d.', sum(baselines));
        end

        types = unique(bursts(5,pstims(4,:)));
        suffix = {'','b'};
        
        for typei = 1:length(types)
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

            labelGroupStarts = [1 3 5];
%             labelGroupStarts = 1:10;
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
            figure
        %     subplot(2,2,1:2);

            prettyline(1e3*t, 1e6*awins(:, keeps), label(keeps), colors);    
        %     ylim([-130 50]);
            xlim(1e3*[min(t) max(t)]);
        %     vline([6 20 40], 'k');
        %     highlight(gca, [25 33], [], [.6 .6 .6])
%             highlight(gca, [0 4], [], [.3 .3 .3]);
%             vline(0.030*1e3);
%             vline(0.080*1e3);
            yl = ylim;
            yl(1) = min(-10, max(yl(1),-120));
            yl(2) = max(10, min(yl(2),100));
            ylim(yl);
            highlight(gca, [0 t(ct)*1e3], [], [.8 .8 .8])
            vline(0);

            xlabel('time (ms)');
            ylabel('ECoG (uV)');
            title(sprintf('EP By N_{CT}: %s, %d', sid, chan))

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

        %     dep_n = 1e6*min(awins(t>0.005 & t < 0.020, keeps));
        %     dep_n = dep_n - mean(dep_n(label(keeps)==0));
        %     
        %     dep_p = 1e6*max(awins(t>0.025 & t < 0.033, keeps));
        %     dep_p = dep_p - mean(dep_p(label(keeps)==0));
        %     
        %     subplot(2,2,3);
        %     prettybar(dep_n, label(keeps), colors, gcf);
        %     set(gca, 'xtick', []);
        %     ylabel('\DeltaEP_N (uV)');
        %     [~,table] = anova1(dep_n', label(keeps), 'off');
        %     title(sprintf('Change in EP_N by N_{CT}: One-Way Anova F=%4.2f p=%0.4f', table{2,5}, table{2,6}));
        %     
        %     pair = {};
        %     p = [];
        %     ulabels = unique(label);
        %     for c = 2:length(ulabels)
        %         [~,p(c-1)] = ttest2(dep_n(label(keeps)==0), dep_n(label(keeps)==ulabels(c)));
        %         pair{c-1} = {1,c};
        %     end
        %     ylim([-12 15]);
        %     
        %     sigstar(pair, p);
        %     
        %     subplot(2,2,4);
        %     prettybar(dep_p, label(keeps), colors, gcf);
        %     set(gca, 'xtick', []);
        %     ylabel('\DeltaEP_P (uV)');
        %     [~,table] = anova1(dep_p', label(keeps), 'off');
        %     title(sprintf('Change in EP_P by N_{CT}: One-Way Anova F=%4.2f p=%0.4f', table{2,5}, table{2,6}));
        %     
        %     pair = {};
        %     p = [];
        %     ulabels = unique(label);
        %     for c = 2:length(ulabels)
        %         [~,p(c-1)] = ttest2(dep_p(label(keeps)==0), dep_p(label(keeps)==ulabels(c)));
        %         pair{c-1} = {1,c};
        %     end
        %     ylim([-12 15]);
        %     
        %     sigstar(pair, p);


            SaveFig(OUTPUT_DIR, sprintf(['ep-%s-%d' suffix{typei}], sid, chan), 'eps', '-r600');    

        %     saveFigure(gcf,fullfile(OUTPUT_DIR, sprintf('ep-%s-%d.eps', sid, chan)));
        %     saveas(gcf,fullfile(OUTPUT_DIR, sprintf('ep-%s-%d.eps', sid, chan)),'eps');
        end
    end
end