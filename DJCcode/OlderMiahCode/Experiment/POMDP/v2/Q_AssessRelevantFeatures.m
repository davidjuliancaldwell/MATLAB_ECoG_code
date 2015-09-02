%% SETUP
Z_Constants;
addpath ./scripts;

%% perform analyses
t.pretable = [];
t.fbtable  = [];
t.alltable = [];

load(fullfile(META_DIR, 'areas.mat'), 'bas', 'hmats');

for sIdx = 1:length(SIDS)
    sid = SIDS{sIdx};
    scode = SCODES{sIdx};
    
    fprintf('working on subject %s\n', sid);
    efile = fullfile(META_DIR, [sid '_epochs.mat']);    
    cfile = fullfile(META_DIR, [sid '_classification.mat']);    

    load(efile, 'montage');
    load(cfile, 'featureRanks', '*R', '*P', '*Ignore');

    nchannels = size(montage.MontageTrodes, 1);
    nfolds = length(featureRanks{1});
    
    % build a table that contains the following for each feature
    % sIdx
    % featIdx
    % bandidx
    % BA
    % HMAT
    % talairach trode x
    % talairach trode y
    % talairach trode z
    % fold1 rank
    % fold2 rank
    % ...
    % foldn rank       
    
    locs = trodeLocsFromMontage(sid, montage, true);
    
    for iter = {{'pretable', 1, preR, preP, preIgnore}, {'fbtable', 2, fbR, fbP, fbIgnore}}
%     for iter = {{'pretable', 1, preR}, {'fbtable', 2, fbR}, {'alltable', 3, allR}}
        tab = iter{1}{1};
        idx = iter{1}{2};
        rho  = iter{1}{3};
        p   = iter{1}{4};
        ig  = iter{1}{5};
        
        nfeatures = length(rho);
        
        for featIdx = 1:nfeatures
%             bandIdx = rem(floor((featIdx-1)/nchannels), length(BAND_TYPE))+1;
            bandIdx = floor((featIdx-1)/nchannels)+1;
            chanIdx = rem(featIdx-1, nchannels)+1;

            newentry = size(t.(tab), 2) + 1;

            t.(tab)(1, newentry) = sIdx;
            t.(tab)(2, newentry) = featIdx;
            t.(tab)(3, newentry) = bandIdx;
            t.(tab)(4, newentry) = bas{sIdx}(chanIdx);
            t.(tab)(5, newentry) = hmats{sIdx}(chanIdx);
            t.(tab)(6, newentry) = locs(chanIdx, 1);
            t.(tab)(7, newentry) = locs(chanIdx, 2);
            t.(tab)(8, newentry) = locs(chanIdx, 3);
            t.(tab)(9, newentry) = rho(featIdx);
            t.(tab)(10, newentry) = p(featIdx) * nchannels;
            t.(tab)(11, newentry) = ig(featIdx);
            
%             for fi = 1:nfolds
%                 t.(tab)(6+fi-1, newentry) = find(featureRanks{1}{fi} == featIdx);
%             end        
        end    
    end
end

%% now give some useful information

%% first, let's visualize the effect.  band by band, let's show all
% electrodes with r2 greater than some threshold.
load('recon_colormap');

for iter = {{'pre', 'pretable', .1},{'fb', 'fbtable',.2}}
    name = iter{1}{1};
    tab = t.(iter{1}{2});
    THRESH = iter{1}{3};

    ubands = unique(tab(3,:));    

    W = [-max(abs(tab(9, ~tab(11, :)))) max(abs(tab(9, ~tab(11, :))))];
    
    for ubandi = 1:length(ubands)
%         keepi = tab(3,:) == ubands(ubandi) & tab(9,:).^2 >= THRESH;
%         keepi = tab(3,:) == ubands(ubandi) & tab(10,:) <= 0.05 & ~tab(11,:);
        keepi = tab(3,:) == ubands(ubandi) & ~tab(11,:); % for the gauss version

        locs = tab(6:8, keepi);
        weights = tab(9, keepi);

        figure
%         PlotDotsDirect('tail', projectToHemisphere(locs', 'r'), weights, 'r', [-1 1], 10, 'recon_colormap', [], false);
        
        PlotGaussDirect('tail', projectToHemisphere(locs', 'r'), weights, 'r', W, 'recon_colormap');
        text(0, 50, 60, sprintf('%.2f', W(2)), 'fontsize', 20);
        
%         colormap(cm);
        title(sprintf('corr %s %s', name, BAND_NAMES{ubandi}));
%         colorbar;

%         SaveFig(OUTPUT_DIR, sprintf('gausscorr_%s_%s', name, BAND_NAMES{ubandi}), 'png', '-r600');
    end
end