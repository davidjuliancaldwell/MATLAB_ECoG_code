%% Constants
Z_Constants;
addpath ./scripts;

%% parameters

% SIDS = SIDS(2:end);
SIDS = SIDS(5);
    
for idx = 1:length(SIDS)
    sid = SIDS{idx};
    
    switch(sid)
        case '8adc5c'
            % sid = SIDS{1};
            tp = 'd:\research\subjects\8adc5c\data\d6\8adc5c_BetaTriggeredStim';
            block = 'Block-67';
            stimchans = [31 32];
            chans = 1:64;
        case 'd5cd55'
            % sid = SIDS{2};
            tp = 'd:\research\subjects\d5cd55\data\d8\d5cd55_BetaTriggeredStim';
            block = 'Block-49';
            stimchans = [54 62];
            chans = 1:64;
        case 'c91479'
            % sid = SIDS{3};
            tp = 'd:\research\subjects\c91479\data\d7\c91479_BetaTriggeredStim';
            block = 'BetaPhase-14';
            stimchans = [55 56];
            chans = 1:64;
        case '7dbdec'
            % sid = SIDS{4};
            tp = 'd:\research\subjects\7dbdec\data\d7\7dbdec_BetaTriggeredStim';
            block = 'BetaPhase-17';
            stimchans = [11 12];
            chans = 1:64;
        case '9ab7ab'
%             sid = SIDS{5};
            tp = 'd:\research\subjects\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim';
            block = 'BetaPhase-3';
            stimchans = [59 60];
            chans = 1:64;
            chans = 51;
        otherwise
            error('unknown SID entered');
    end
    
    %% load in the trigger data
    load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts', 'fs', 'stims');

    % drop any stims that happen in the first 500 milliseconds
    stims(:,stims(2,:) < fs/2) = [];

    % drop any probe stimuli without a corresponding pre-burst/post-burst
    bads = stims(3,:) == 0 & (isnan(stims(4,:)) | isnan(stims(6,:)));
    stims(:, bads) = [];

    % preallocate storage
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
    else
        error 'unknown sid'; 
    end
    
    stats = zeros(6, sum(pts), length(chans));
    
    %% process each ecog channel individually
    for chan = chans
        if (~ismember(chan, stimchans)) % we're ignoring the stim channels
            %% load in ecog data for that channel
            fprintf('loading in ecog data:\n');
            tic;    
            grp = floor((chan-1)/16);
            ev = sprintf('ECO%d', grp+1);
            achan = chan - grp*16;

            [eco, efs] = tdt_loadStream(tp, block, ev, achan);

            toc;

            fac = fs/efs;

            %% preprocess eco    
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

            eco = bandpass(eco, 1, 200, efs, 4, 'causal');
            
%             warning ('not notch filtering.');
            eco = notch(eco, [60 120 180], efs, 2, 'causal');

            %% process triggers
            ptis = round(stims(2,pts)/fac);

            t = (-presamps:postsamps)/efs;

            wins = squeeze(getEpochSignal(eco', ptis-presamps, ptis+postsamps+1));

            % normalize the windows to each other, using pre data
            awins = wins-repmat(mean(wins(t<0,:),1), [size(wins, 1), 1]);
                
            pstims = stims(:,pts);

            % calculate EP statistics
            stats(:,:,chan) = quantifyEPs(t, awins);
        end
    end
    
    save(fullfile(META_DIR, sprintf('ep_tables_%s.mat', sid)), 'stats', 'pstims');
end