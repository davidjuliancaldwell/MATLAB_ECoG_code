Z_Constants;

%% 
subjectList = SIDS;

counter = 0;

for counter = 1:length(subjectList)
    
    sid = subjectList{counter};
    
    fprintf(' working on subject %d: %s\n', counter, sid);
    
    rawFiles = listDatFiles(sid, '_ud');
    storageTimes = [];
    controlElectrodes = [];
%     adapting = [];
    
    keepers = ones(size(rawFiles));
    
    for fileIdx = 1:length(rawFiles)
        if (~isempty(strfind(rawFiles{fileIdx}, 'combined')) || ...
            ~isempty(strfind(rawFiles{fileIdx}, 'eyebrows')) || ...
            ~isempty(strfind(rawFiles{fileIdx}, '3targ')) || ...
            ~isempty(strfind(rawFiles{fileIdx}, '5targ')) || ...
            ~isempty(strfind(rawFiles{fileIdx}, 'manual')) || ...
            ~isempty(strfind(rawFiles{fileIdx}, 'hold')) || ...
            ~isempty(strfind(rawFiles{fileIdx}, 'verb')) || ...
            ~isempty(strfind(rawFiles{fileIdx}, '7ee6bc_ud_imS001R09')) || ...
            ~isempty(strfind(rawFiles{fileIdx}, '7ee6bc_ud_imS001R10')) || ...
            ~isempty(strfind(rawFiles{fileIdx}, '7ee6bc_ud_imS001R11')) || ...
            ~isempty(strfind(rawFiles{fileIdx}, '7ee6bc_ud_imS001R12')) || ...
            ~isempty(strfind(rawFiles{fileIdx}, '7ee6bc_ud_imS001R13')) || ...
            ~isempty(strfind(rawFiles{fileIdx}, '7ee6bc_ud_imS001R14')) || ...
            ~isempty(strfind(rawFiles{fileIdx}, 'left_hand')) || ...
            ~isempty(strfind(rawFiles{fileIdx}, '38e116_ud_im_hS001R02')))
        
        % those 7ee6bc files have been removed from the analysis because
        % the feedback length changed from 3s to 2s b/w r09 and r14 ...
        % which is annoying for analysis purposes
        
            keepers(fileIdx) = 0;
            storageTimes(fileIdx) = 0;
            controlElectrodes(fileIdx) = 0;
        else
            [~,sta,par] = load_bcidat(rawFiles{fileIdx});

            [~, ntrials] = determinePerformance(sta);
            storageTimes(fileIdx) = extractRecordingDate(par);
            controlElectrodes(fileIdx) = extractControlElectrode(par);
%             adapting(fileIdx) = sum(par.Adaptation.NumericValue(1)) > 0;
            
            if (ntrials <= 3)
                % check file for requirements, if it doesn't pass
                keepers(fileIdx) = 0;
            end
        end
    end

    % only use files where the control electrode was consistent with the
    % most commonly used control electrode
    keepers = keepers == 1 & controlElectrodes == mode(controlElectrodes(keepers==1));
    
    keepFiles = rawFiles(keepers);
    keepTimes = storageTimes(keepers);
    keepTrodes = controlElectrodes(keepers);
%     keepAdapting = adapting(keepers)
   
    if (length(unique(keepTrodes)) > 1)
        warning('multiple control electrodes listed, using the most common (%d):', mode(keepTrodes));        
        fprintf(' %d', keepTrodes);
        fprintf('\n');
        controlTrode = mode(keepTrodes);
    else
        controlTrode = keepTrodes(end);
    end
    
    [~, sortedIndices] = sort(keepTimes);    
    fileInfo(counter).files = keepFiles(sortedIndices);
    
    Montage = getCommonMontage(fileInfo(counter).files);
    
    fileInfo(counter).bads = Montage.BadChannels;    
    hemi = determineHemisphereOfCoverage(sid);
    fileInfo(counter).hemi = hemi;
    fileInfo(counter).montage = Montage;
    fileInfo(counter).control = keepTrodes(end); % use the final one in case there are more than one
    
%     figure, PlotCortex(sid, hemi);
%     PlotElectrodes(sid);
%     title([sid ' - ' hemi]);

end

save(fullfile(META_DIR, 'fileInfo.mat'), 'fileInfo', 'subjectList');
