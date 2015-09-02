Z_Constants;

addpath ./scripts;

%% store all of the significant for all subjects tstat values 
load(fullfile(META_DIR, 'areas.mat'));

SIDS(7) = [];
bas(7) = [];
hmats(7) = [];

% mlabels = {'M1', 'S1', 'SMA', 'PMd', 'PMv', 'PPC',    'PFC'};
% mtype   = [   1,    1,     1,     1,     1,     2,        2]; % 1 is HMAT, 2 is BA
% mmatch  = { 1:2,  3:4,   5:8,  9:10, 11:12, [5 7], [46]};

mlabels = {'BA1', 'BA4', 'BA6', 'BA44', 'BA45', 'BA46', 'BA8', 'BA9'};
mtype   = [    2,     2,     2,      2,      2,      2,     2,     2];
mmatch  = {    1,     4,     6,     44,     45,     46,     8,     9};

% allbas = union(mmatch{mtype == 2});

sigacts = cell(length(SIDS), 1);
coverages = cell(length(SIDS), 1);

allts = cell(6, 1);
alltrodes = [];

for c = 1:length(SIDS)
    sid = SIDS{c};
    fprintf('loading data for subject %s\n', sid);

    load(fullfile(META_DIR, sprintf('ts_analysis_%s', sid)), 'tstats', 'blob*', 'montage', 'rt', 'tgts', 'sigthresh');    
    
    numtrodes = size(tstats{1}, 1);
    
    % first classify all the electrodes as belonging to a motor group,
    % posterior parietal or pre-frontal
        
    hmat = hmats{c};
    ba = bas{c};
    
    trodetype = zeros(numtrodes, 1);
    
    for tr = 1:numtrodes
        for idx = 1:length(mlabels)
            if (mtype(idx) == 1)
                if (any(hmat(tr) == mmatch{idx}))
                    trodetype(tr) = idx;
                    break;
                end                            
            else % mtype(idx) == 2
                if (any(ba(tr) == mmatch{idx}))
                    trodetype(tr) = idx;
                    break;
                end
            end
        end
    end
    

    % now, determine whether there was a significant change in one or more electrode
    % for each motor group
%     figure
%     PlotDotsDirect(sid, trodeLocsFromMontage(sid, montage, false), trodetype, determineHemisphereOfCoverage(sid), [0 7], 10, 'recon_colormap', [], false, false);
%     load recon_colormap;
%     colormap(cm);
%     colorbar;

    temp = trodeLocsFromMontage(sid, montage, true);
    temp = temp(1:size(tstats{1}, 1), :);
    temp = projectToHemisphere(temp, 'r');
    
    alltrodes = cat(1, alltrodes, temp);
    
    for bandi = 1:length(BAND_NAMES)
        allts{bandi} = cat(1, allts{bandi}, tstats{bandi});
        
        % significance screen the t-stats
        sigblobs = find(blobsize{bandi} >= sigthresh(bandi));
        tstats{bandi}(~ismember(gridToLin(blobs{bandi}, 1:2), sigblobs)) = 0;
        
        
        for idx = 1:length(mlabels)            
            % check each area to see (a) the number of electrodes with
            % coverage and (b) the number of electrodes with a significant
            % change
            trodes = trodetype==idx;
            
            coverages{c}(bandi, idx) = sum(trodes);
%             sum(trodes)
%             plot(tstats{bandi}(trodes, :)')
%             title(sprintf('%d %d', bandi, idx));
%             if (sum(trodes) ~= 0)
                sigacts{c}(bandi, idx, :) = sum(tstats{bandi}(trodes, :) ~= 0, 1);
%             end            
        end
    end
end

%% now let's visualize the results

acts = cat(4, sigacts{:});
cnts = cat(4, coverages{:});

% we want to see the fraction of subjects that had
frac = zeros(length(BAND_NAMES), length(mlabels), size(acts, 3));

foo = sum(acts>0, 4);
foo2 = repmat(sum(cnts>0,4), [1 1 size(foo, 3)]);

frac = foo ./ foo2;

% remove any areas that don't occur in anyone
bads = squeeze(mean(mean(foo2, 1), 3)) == 0;
tlabels = mlabels(~bads);
frac(:, bads, :) = [];

% now make a few plots
for bandi = 1:length(BAND_NAMES)
    figure

%     v = squeeze(frac(bandi, :, :));
    v = squeeze(frac(bandi, :, :)) - repmat(((1:size(frac,2)) - 1)', [1, size(frac, 3)]);
    plot(rt, v, 'linew', 2);
    legend(tlabels, 'location', 'northwestoutside');
    xlabel('Time (s)');
    ylabel('Fraction showing significant changes');
    title(BAND_NAMES{bandi});
%     ylim([-.1 1]);
    xlim([-2 3]);
    vline(0, 'k:');
    SaveFig(fullfile(OUTPUT_DIR), sprintf('tline-%d', bandi), 'eps', '-r600');

end

% todo SAVE

%% and look at tscores across brain / time

ts = -1:.5:2.5;

for bandi = 5
    for t = ts
        ti = find(rt>=t, 1, 'first');

        if (bandi == 3 || bandi == 4)
            clim = 5;
        else
            clim = 5;
        end
        
        figure
        PlotGaussDirect('tail', alltrodes, allts{bandi}(:, ti), 'r', [-clim clim], 'recon_colormap');
        load('recon_colormap');
        colormap(cm);
        setColorbarTitle(colorbar, 't-statistic');
        
%         PlotDotsDirect('tail', alltrodes, allts{bandi}(:, ti), 'r', [-3 3], 10, 'recon_colormap', [], false);
        title(sprintf('%s @ t = %1.2f', BAND_NAMES{bandi}, rt(ti)));
        
        SaveFig(fullfile(OUTPUT_DIR), sprintf('tal-%d-%f', bandi, rt(ti)), 'png', '-r600');
    end
end
