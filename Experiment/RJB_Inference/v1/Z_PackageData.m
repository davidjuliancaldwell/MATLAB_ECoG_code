%% this script collects BCI data in to relevant epochs and stores a cache file

Z_Constants;
addpath ./scripts

%% 

for zid = SIDS
    sid = zid{:};
    [ftemp, hemi, bads, montage, cchan] = filesForSubjid(sid);

    sigs = cell(size(ftemp));
    stas = cell(size(ftemp));
    pars = cell(size(ftemp));
    
    idx = 0;    
    for mfile = ftemp
        idx = idx + 1;

        fprintf('working on file %s\n', mfile{:});

        % load the data fille
        [sigs{idx}, stas{idx}, pars{idx}] = load_bcidat(mfile{:});
       
        fs = pars{idx}.SamplingRate.NumericValue;
        
        % downsample to 600 hz / 500 Hz to keep stats reasonable
        if (fs == 2400)
            % common average re-ref
            sigs{idx} = ReferenceCAR(GugerizeMontage(montage.Montage), bads, double(sigs{idx}));
            
            for c = 1:size(sigs{idx},2)
                sig2(:,c) = resample(sigs{idx}(:,c), 1, 2);
            end

            sigs{idx} = sig2; clear sig2;

            stas{idx}.TargetCode = stas{idx}.TargetCode(1:2:end);
            stas{idx}.ResultCode = stas{idx}.ResultCode(1:2:end);
            stas{idx}.Feedback   = stas{idx}.Feedback(1:2:end);

            if (hasPaths(stas{idx}))
                stas{idx}.CursorPosX = stas{idx}.CursorPosX(1:2:end);
                stas{idx}.CursorPosY = stas{idx}.CursorPosY(1:2:end);
            end
            
            pars{idx}.SamplingRate.NumericValue = 1200;
            
        elseif (fs == 1200)
            % common average re-ref
            sigs{idx} = ReferenceCAR(GugerizeMontage(montage.Montage), bads, double(sigs{idx}));
            
        elseif (fs == 1000)
            % common average re-ref
            sigs{idx} = ReferenceCAR(montage.Montage, bads, double(sigs{idx}));
        else
            error('unknown fs');
        end

    end

    % clear unsaved variables
    clear bi c e e_ctr fends files* fstarts ftemp mepochs mfile par pends rends rstarts sig sta mepochs_beta mepochs_hg
    clear beta hg lf maxx maxy mepochs_lf minx miny mpaths savingCursorInfo temp

    % save the rest
    save(fullfile(META_DIR, [sid '_packaged']), 'montage', 'bads', 'sigs', 'stas', 'pars', 'cchan', 'hemi');
end