%%
Z_Constants;
addpath ./scripts

%%
load(fullfile(META_DIR, 'screened_interactions.mat'), 'result');
badsub = find(strcmp(SIDS, '38e116'));
result(ismember(result(:, 1), badsub), :) = [];

%% look at high gamma interactions
keeps = (result(:,10)  <= 0.05 & result(:, 9)==1);
fprintf('%d HG-HG interactions on unaligned trials\n', sum(keeps));
fprintf('  from %d of %d subjects\n', length(unique(result(keeps, 1))), length(unique(result(:, 1))));

%% look at them by class
res = hist(result(keeps, 6), 3)

%% look at all the other interaction types

types = 2:5;
typeLabels = {'c_hg-r_beta', 'c_hg-r_alpha', 'c_beta-r_hg', 'c_alpha-r_hg'};

for idx = 1:length(types)
    keeps = (result(:,10)  <= 0.05 & result(:, 9)==types(idx));
    fprintf('for %s, there was/were %d interaction(s)\n', typeLabels{idx}, sum(keeps));
end

%% talk about the timing of the interactions