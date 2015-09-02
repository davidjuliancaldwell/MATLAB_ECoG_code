%% plot all of the features of interest on one or more brains
%
% what's the best way to do this?  I've got a set of predictive and
% reactive HG / LF features, that's a two by two matrix.  I have this for 
% the five subjects, so that's 2x2x5.
%
% I think the most compelling way to look at these data will be a single 
% Talairach brain for all 5 subjects, showing a specific freq/time combo,
% making for 4 brains in all.  Oh yeah, and there's the whole medial
% lateral thing as well, so tack on a few more brains.  4 pairs of views
%

%% collect all electrodes

HG = 1; LF = 2;
PRE = 1; RE = 2;

allLocs = cell(2, 2);
allVals = cell(2, 2);
contributors = cell(2, 2);

subjids = {'fc9643', ... 
           '4568f4', ... 
           '30052b', ... 
           '9ad250', ... 
           '38e116'};

for snum = 1:length(subjids)
    subjid = subjids{snum};
    
    % load in the electrodes for this subject
    [~, odir, hemi] = filesForSubjid(subjid);
    load(fullfile(odir, [subjid '_features']), 'rehs*', 'prehs*', 'restats*', 'prestats*', 'locst');
    
    % pluck out the electrodes of interest
    for freq = 1:2
        for time = 1:2
            switch (freq)
                case HG
                    switch (time)
                        case PRE
                            mlocs = locst(prehs_hg==1, :);
                            mlocs(:,1) = abs(mlocs(:,1));
                            mvals = prestats_hg.tstat(prehs_hg==1);
                        case RE
                            mlocs = locst(rehs_hg==1, :);
                            mlocs(:,1) = abs(mlocs(:,1));
                            mvals = restats_hg.tstat(rehs_hg==1);
                    end
                case LF
                    switch (time)
                        case PRE
                            mlocs = locst(prehs_lf==1, :);
                            mlocs(:,1) = abs(mlocs(:,1));
                            mvals = prestats_lf.tstat(prehs_lf==1);                            
                        case RE
                            mlocs = locst(rehs_lf==1, :);
                            mlocs(:,1) = abs(mlocs(:,1));
                            mvals = restats_lf.tstat(rehs_lf==1);                            
                    end
            end
            
            allLocs{freq, time} = cat(1, allLocs{freq, time}, mlocs);
            allVals{freq, time} = cat(1, allVals{freq, time}, mvals);
            contributors{freq, time} = cat(1, contributors{freq, time}, ones(size(mvals))*snum);
        end        
    end
end

dest = fullfile(fileparts(odir), 'figs');

for freq = 1:2
    for time = 1:2
        % do the plotting of the brain
        figure;
%         PlotCortex('tail', 'r');
        PlotDotsDirectWithCustomMarkers('tail', allLocs{freq, time}, -allVals{freq, time}, 'r', [-10 10], 10, contributors{freq, time}, 'recon_colormap');
        
        view(90,0);
        SaveFig(dest, sprintf('feats-l.freq%d.time%d.png', freq, time), 'png', '-r600');
        view(270,0);
        SaveFig(dest, sprintf('feats-m.freq%d.time%d.png', freq, time), 'png', '-r600');        
    end
end

        

