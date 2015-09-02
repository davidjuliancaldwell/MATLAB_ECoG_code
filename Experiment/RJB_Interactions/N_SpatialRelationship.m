%% POSITIVE LAG IMPLIES CONTROL LEADS
addpath ./scripts
Z_Constants;

SID = 1;
CHAN = 2;
TAL = 3:5;
CLASS = 6;
HMAT = 7;
BA = 8;
TYPE = 9;
SIG = 10;
WEIGHT = 11;
TIME = 12;
LAG = 13;

%%
load(fullfile(META_DIR, 'screened_interactions.mat'), '*result*', 'controlLocs');

%% because it's interesting, let's figure out which electrodes changed over 
% the course of learning

%delete
all_t = [];
all_loc = [];
all_ids = [];
%

changed = zeros(size(resultA, 1), 1);

for sidx = unique(resultA(:,1))'
    sid = SIDS{sidx};
    load(fullfile(META_DIR, [sid '_results']), 'flu*', 'snr*', 'groupRes', 'regRes');
    load(fullfile(META_DIR, [sid '_epochs']),'bad_channels', 'cchan', 'montage');
    
%     fluH(bad_channels) = [];
%     fluH(cchan) = [];
%     fluT(bad_channels) = [];
%     fluT(cchan) = [];
%     
%     fluT(~fluH) = NaN;
%     
%     any(fluH)
%     idxs = resultA(:,1) == sidx & resultA(:,TYPE)==5;    
%     changed(idxs) = fluH;
%     
%     all_t = cat(1, all_t, fluT);
%     all_loc = cat(1, all_loc, resultA(idxs, TAL));
%     all_ids = cat(1, all_ids, sidx* ones(size(fluT)));

%     all_t = cat(1, all_t, (snr_l - snr_e)./snr_e);
    all_t = cat(1, all_t, regRes(:,1) .* double(regRes(:,2) < 0.05));
    all_loc = cat(1, all_loc, trodeLocsFromMontage(sid, montage, true));
    all_ids = cat(1, all_ids, sidx* ones(size(snr_l)));
    
end

keeps = resultA(:, TYPE) == 1 & resultA(:, SIG) <= 0.05;
sum(keeps & changed)

keeps = result(:, TYPE) == 1 & result(:, SIG) <= 0.05;
sum(keeps & changed)

all_t(all_t==0)=NaN;

figure
PlotDotsDirect('tail', projectToHemisphere(all_loc, 'r'), all_t, 'r', [-max(abs(all_t)) max(abs(all_t))]*.5, 10, 'america', all_ids, true);
load('america');
colormap(cm);
colorbarLabel('regression coefficient');

%% drop the conspicuous subject
badsub = [];
badsub = find(strcmp(SIDS, '38e116'));

resultA(ismember(resultA(:,1), badsub), :) = [];
% resultA(:, LAG) = -resultA(:, LAG);

earlyresultA(ismember(earlyresultA(:,1), badsub), :) = [];
% earlyresultA(:, LAG) = -earlyresultA(:,LAG);

lateresultA(ismember(lateresultA(:,1), badsub), :) = [];
% lateresultA(:, LAG) = -lateresultA(:,LAG);

result(ismember(result(:,1), badsub), :) = [];
% result(:, LAG) = -result(:, LAG);

earlyresult(ismember(earlyresult(:,1), badsub), :) = [];
% earlyresult(:, LAG) = -earlyresult(:, LAG);

lateresult(ismember(lateresult(:,1), badsub), :) = [];
% lateresult(:, LAG) = -lateresult(:, LAG);

SIDS(badsub) = [];
SCODES(badsub) = [];

%% this script is in the business of showing the following
% (a) overall coverage maps of considered electrodes
% (b) electrodes showing task modulation
% (c) electrodes showing significant interactions

% for starters, we'll kick out some basic numbers, and show plots on the 
% talairach brain.  It may also make sense to break down by area

%allareas = [];
alllocs = [];

for sIdx = 1:length(SIDS)
    sid = SIDS{sIdx};
    
    [~, ~, ~, montage, cchan] = filesForSubjid(sid);
    load(fullfile(META_DIR, [sid '_bad_trials.mat']));    
    
    mlocs = trodeLocsFromMontage(sid, montage, true);
    
    mlocs(bad_channels, :) = [];
    mlocs(cchan, :) = [];
    
    alllocs = cat(1, alllocs, mlocs);
end

%% do the brain plots for the aligned / unaligned interactions

% figure
% PlotGaussDirect('tail', projectToHemisphere(alllocs, 'r'), ones(size(alllocs, 1), 1), 'r', [-1 1], 'recon_colormap');
% PlotDotsDirect('tail', projectToHemisphere(alllocs, 'r'), NaN*ones(size(alllocs, 1), 1), 'r', [-1 1], 20, 'recon_colormap', [], false, true);
% title('all electrodes');
% SaveFig(OUTPUT_DIR, 'coverage_all', 'png', '-r600');

%%
figure
considered = resultA(:, TYPE)==1;
consideredLocs = resultA(considered, TAL);
consideredAreas = resultA(considered, HMAT);
nc = zeros(size(consideredAreas));
nc(ismember(consideredAreas, [1 2])) = 1;
nc(ismember(consideredAreas, [3 4])) = 2;
nc(ismember(consideredAreas, [9 10])) = 3;
nc(ismember(consideredAreas, [11 12])) = 4;
% nc(ismember(consideredAreas, [5 6 7 8])) = 5;

%PlotGaussDirect('tail', projectToHemisphere(consideredLocs, 'r'), ones(size(consideredLocs, 1), 1), 'r', [-1 1], 'recon_colormap');
% PlotDotsDirect('tail', projectToHemisphere(consideredLocs, 'r'), NaN*ones(size(consideredLocs, 1), 1), 'r', [-1 1], 20, 'recon_colormap', [], false, true);
load('temp_colormap'); 
PlotDotsDirect('tail', projectToHemisphere(consideredLocs, 'r'), nc, 'r', [0 5], 6, cm, [], false, false);
colormap(cm);

title('all electrodes');
SaveFig(OUTPUT_DIR, 'coverage_all', 'png', '-r600');

%%
figure
inters = resultA(:, TYPE)==1 & resultA(:, SIG) <= 0.05;
interactionLocs = resultA(inters, TAL);

interactionAreas = resultA(inters, HMAT);
nc = zeros(size(interactionAreas));
nc(ismember(interactionAreas, [1 2])) = 1;
nc(ismember(interactionAreas, [3 4])) = 2;
nc(ismember(interactionAreas, [9 10])) = 3;
nc(ismember(interactionAreas, [11 12])) = 4;
nc(ismember(interactionAreas, [5 6 7 8])) = 5;

% PlotGaussDirect('tail', projectToHemisphere(interactionLocs, 'r'), ones(size(interactionLocs, 1), 1), 'r', [-1 1], 'recon_colormap');
% PlotDotsDirect('tail', projectToHemisphere(interactionLocs, 'r'), NaN*ones(size(interactionLocs, 1), 1), 'r', [-1 1], 20, 'recon_colormap', [], false, true);

load('temp_colormap'); 
PlotDotsDirect('tail', projectToHemisphere(interactionLocs, 'r'), nc, 'r', [0 5], 8, cm, [], false, false);
colormap(cm);

title('interacting electrodes (aligned)');
SaveFig(OUTPUT_DIR, 'coverage_interact_aligned', 'png', '-r600');

%%
figure
inters = result(:, TYPE)==1 & result(:, SIG) <= 0.05;
interactionLocs = result(inters, TAL);

interactionAreas = result(inters, HMAT);
nc = zeros(size(interactionAreas));
nc(ismember(interactionAreas, [1 2])) = 1;
nc(ismember(interactionAreas, [3 4])) = 2;
nc(ismember(interactionAreas, [9 10])) = 3;
nc(ismember(interactionAreas, [11 12])) = 4;
% nc(ismember(interactionAreas, [5 6 7 8])) = 5;

% PlotGaussDirect('tail', projectToHemisphere(interactionLocs, 'r'), ones(size(interactionLocs, 1), 1), 'r', [-1 1], 'recon_colormap');
% PlotDotsDirect('tail', projectToHemisphere(interactionLocs, 'r'), NaN*ones(size(interactionLocs, 1), 1), 'r', [-1 1], 20, 'recon_colormap', [], false, true);

load('temp_colormap'); 
PlotDotsDirect('tail', projectToHemisphere(interactionLocs, 'r'), nc, 'r', [0 5], 8, cm, [], false, false);
colormap(cm);

title('interacting electrodes (unaligned)');
SaveFig(OUTPUT_DIR, 'coverage_interact_unaligned', 'png', '-r600');

%% and print some stuff out
nEffort = sum(resultA(resultA(:, TYPE)==1, CLASS)==2);
nCtl = sum(resultA(resultA(:, TYPE)==1, CLASS)==1);
nIntSubsAl = length(unique(resultA(resultA(:, TYPE)==1 & resultA(:, SIG)<0.05, SID)));
nIntSubsUnal = length(unique(result(result(:, TYPE)==1 & result(:, SIG)<0.05, SID)));

fprintf(['Of %d electrodes that were included in the analysis, %d electrodes ' ...
         'showed significant \ncontrol-like (%d) or effort-like (%d) modulation ' ...
         'of HG activity.  Of these electrodes, \n%d showed significant HG-HG ' ...
         'interactions of aligned trials.  \nAligned interactions were observed in ' ...
         '%d of %d subjects.  %d showed significant HG-HG interactions ' ...
         'of unaligned trials.  \nUnaligned interactions were observed in ' ...
         '%d of %d subjects.\n'], size(alllocs, 1), size(consideredLocs, 1), nEffort, nCtl, ...
         size(interactionLocs, 1), nIntSubsAl, length(SIDS), size(unalignedInteractionLocs, 1), ...
         nIntSubsUnal, length(SIDS));