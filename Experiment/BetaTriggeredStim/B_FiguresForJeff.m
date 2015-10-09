%% 9-9-2015 - make figures for Jeff, according to this email
%
% HI David - these are great. It sure looks like the phase doesn't matter much.
%
% Ideally, a bar plot showing the CCEP amplitude from zero, one, or multiple stims (maybe combined across all beta conditions) would be nice. Whatever is quick.
%
% ALso, from an earlier subject, I have data on spatial specificity (ie, the CCEP only goes up for the recorded electrode, or at least more for that electrode than others). Can you reproduce that phenomenon in this subject?
%
% Thanks

%% Bar Plot
% for subject ecb43e

chans = [47 55];

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
    
    %% preprocess eco
    %             presamps = round(0.050 * efs); % pre time in sec
    presamps = round(0.025 * efs); % pre time in sec
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
    
    % DJC - 8-31-2015 - i believe this is messing with the resizing
    % in the figures
    %             subplot(8,8,chan);
    %             plot(foo);
    %             vline(ct);
    %
    for sti = 1:length(sts)
        win = (sts(sti)-presamps):(sts(sti)+postsamps+1);
        
        % interpolation approach
        eco(win(presamps:(ct-1))) = interp1([presamps-1 ct], eco(win([presamps-1 ct])), presamps:(ct-1));
    end
    %
    eco = toRow(bandpass(eco, 1, 40, efs, 4, 'causal'));
    eco = toRow(notch(eco, 60, efs, 2, 'causal'));
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
    
    probes = pstims(5,:) < .250*fs;
    % label the stimuli pulses based off
    label = bursts(4,pstims(4,probes));
    
    %modify this to change groupings/stratifications - djc 8/31/2015
    
    kwins = awins(:,probes);
    
    peakBegin = 0.005;
    peakEnd = size(awins,1);
    peakRange = find(t>=peakBegin & t<=peakEnd);
    
    peakMax = min((kwins(peakRange,:)));
    
    
    labelGroupStarts = [1 3 5];
    %     labelGroupStarts = [1:2:10];
    %                 labelGroupStarts = 1:10;
    %     labelGroupStarts = 1:5;
    labelGroupEnds   = [labelGroupStarts(2:end) Inf];
    
    for gIdx = 1:length(labelGroupStarts)
        labeli = label >= labelGroupStarts(gIdx) & label < labelGroupEnds(gIdx);
        label(labeli) = gIdx;
    end
    
    
    
    
    figure
    load('line_colormap.mat')
    klabel = label;
    ulabels = unique(klabel);
    colors = cm(round(linspace(1, size(cm, 1), length(ulabels))), :);
    
    prettybar(peakMax*1e6,label,colors)
    %     yl = ylim;
    %     yl(1) = min(-10, max(yl(1),-120));
    %     yl(2) = max(10, min(yl(2),100));
    %     ylim(yl);
    ylabel('ECoG (uV)');
    set(gca,'Xtick',[])
    title(sprintf('Evoked Potentials Magnitude by # of conditioning pulses for Channel %d',chan));
    leg = {'Null condition'};
    for d = 1:length(labelGroupStarts)
        if d == length(labelGroupStarts)
            leg{end+1} = sprintf('%d<=CT', labelGroupStarts(d));
        else
            leg{end+1} = sprintf('%d<=CT<%d', labelGroupStarts(d), labelGroupEnds(d));
        end
    end
    legend(leg, 'location', 'Southwest')
    
    
    SaveFig(OUTPUT_DIR, sprintf(['EPampByStimNum-%s-%d'], sid, chan), 'eps', '-r600');
    SaveFig(OUTPUT_DIR, sprintf(['EPampByStimNum-%s-%d'], sid, chan), 'png', '-r600');
    SaveFig(OUTPUT_DIR, sprintf(['EPampByStimNum-%s-%d'], sid, chan), 'fig', '-r600');
    
    
end


%% spatial specificity

% for subject ecb43e

chans = [38 39 46 47 48 54 55 62 63];
figure
i = 1;
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
    
    %% preprocess eco
    %             presamps = round(0.050 * efs); % pre time in sec
    presamps = round(0.025 * efs); % pre time in sec
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
    
    % DJC - 8-31-2015 - i believe this is messing with the resizing
    % in the figures
    %             subplot(8,8,chan);
    %             plot(foo);
    %             vline(ct);
    %
    for sti = 1:length(sts)
        win = (sts(sti)-presamps):(sts(sti)+postsamps+1);
        
        % interpolation approach
        eco(win(presamps:(ct-1))) = interp1([presamps-1 ct], eco(win([presamps-1 ct])), presamps:(ct-1));
    end
    %
    eco = toRow(bandpass(eco, 1, 40, efs, 4, 'causal'));
    eco = toRow(notch(eco, 60, efs, 2, 'causal'));
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
    
    probes = pstims(5,:) < .250*fs;
    % label the stimuli pulses based off
    label = bursts(4,pstims(4,probes));
    
    %modify this to change groupings/stratifications - djc 8/31/2015
    
    kwins = awins(:,probes);
    
    peakBegin = 0.005;
    peakEnd = size(awins,1);
    peakRange = find(t>=peakBegin & t<=peakEnd);
    
    peakMax = min((kwins(peakRange,:)));
    
    
    labelGroupStarts = [1 3 5];
    %     labelGroupStarts = [1:2:10];
    %                 labelGroupStarts = 1:10;
    %     labelGroupStarts = 1:5;
    labelGroupEnds   = [labelGroupStarts(2:end) Inf];
    
    for gIdx = 1:length(labelGroupStarts)
        labeli = label >= labelGroupStarts(gIdx) & label < labelGroupEnds(gIdx);
        label(labeli) = gIdx;
    end
    
    
    
    
    h = subplot(3,3,i)
    load('line_colormap.mat')
    klabel = label;
    ulabels = unique(klabel);
    colors = cm(round(linspace(1, size(cm, 1), length(ulabels))), :);
    
    prettybar(peakMax*1e6,label,colors,h)
    %     yl = ylim;
    %     yl(1) = min(-10, max(yl(1),-120));
    %     yl(2) = max(10, min(yl(2),100));
    %     ylim(yl);
    
    set(gca,'Xtick',[])
    title(sprintf('Channel %d',chan));
    
    
    i = i+1;
    
    if i == 10
        ylabel('ECoG (uV)');
        leg = {'Null condition'};
        for d = 1:length(labelGroupStarts)
            if d == length(labelGroupStarts)
                leg{end+1} = sprintf('%d<=CT', labelGroupStarts(d));
            else
                leg{end+1} = sprintf('%d<=CT<%d', labelGroupStarts(d), labelGroupEnds(d));
            end
        end
        legend(leg, 'location', 'Southwest')
    end
    
    
end
subtitle((sprintf('Spatial Specificity - Evoked Potentials Magnitude by # of conditioning pulses',chan)));



%%
SaveFig(OUTPUT_DIR, sprintf(['EPampSpatial-%s'], sid), 'eps', '-r600');
SaveFig(OUTPUT_DIR, sprintf(['EPampSpatial-%s'], sid), 'png', '-r600');
