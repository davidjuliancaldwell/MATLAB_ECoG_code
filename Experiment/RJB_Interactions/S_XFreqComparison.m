%%
Z_Constants;
addpath ./scripts

%%
load(fullfile(META_DIR, 'screened_interactions.mat'), 'resultA');
badsub = find(strcmp(SIDS, '38e116'));
resultA(ismember(resultA(:, 1), badsub), :) = [];

%% look at all the other interaction types

types = 2:5;
typeLabels = {'c_hg-r_beta', 'c_hg-r_alpha', 'c_beta-r_hg', 'c_alpha-r_hg'};

for idx = 1:length(types)
    keeps = (resultA(:,10)  <= 0.05 & resultA(:, 9)==types(idx));
    fprintf('for %s, there was/were %d interaction(s)\n', typeLabels{idx}, sum(keeps));
end