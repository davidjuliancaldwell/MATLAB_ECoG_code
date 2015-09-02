Z_Constants;
chans = [11 45 17 31 36 25 12 30 57 10 16];
load(fullfile(META_DIR, 'areas.mat'));

%% print things out to verify I've handwritten stuff correctly

for sIdx = 1:length(SIDS)
    fprintf('%s %d\n', SIDS{sIdx}, chans(sIdx));
end

%% collect the electrode locations for all of the trodes listed above

locs = [];
labels = {};
hs = [];
bs = [];
shape = [];
w = [];

for sIdx = 1:length(SIDS)
    sid = SIDS{sIdx};
    
    load(fullfile(META_DIR, [sid '_epochs.mat']), 'montage', 'cchan');
    slocs = trodeLocsFromMontage(sid, montage, true);
    
    if strcmp(determineHemisphereOfCoverage(sid), 'l')
        shape(end+1) = 2;
        shape(end+1) = 2;
    else
        shape(end+1) = 1;
        shape(end+1) = 1;
    end
    
    locs([end+1 end+2],:) = projectToHemisphere(slocs([cchan chans(sIdx)], :), 'r') + [5 0 0; 5 0 0];    
    
    w(end+1) = -.25;
    w(end+1) = .25;
    
    labels{end+1} = sid(1:2);
    labels{end+1} = sid(1:2);

    hs(end+1) = NaN;
    hs(end+1) = hmats{sIdx}(chans(sIdx));
    
    bs(end+1) = NaN;
    bs(end+1) = bas{sIdx}(chans(sIdx));
end

%% display them

figure
% PlotDotsDirect('tail', locs, zeros(size(hs)), 'r', [-1 1], 20, 'recon_colormap', labels, true);
PlotDotsDirectWithCustomMarkers('tail', locs, w, 'r', [-1 1], 20, shape, 'recon_colormap', labels, true);
maximize;
SaveFig(OUTPUT_DIR, 'bPLV_locs', 'png', '-r300');
