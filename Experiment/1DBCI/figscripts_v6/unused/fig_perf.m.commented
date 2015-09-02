%% analysis for determining division points in the control electrode
%% by maximizing the separability of the early-late distributions

% common across all remote areas analysis scripts
subjids = {
    '26cb98'
    '04b3d5'
    '38e116'
    '4568f4'
    '30052b'
    'fc9643'
    'mg'
    };

for c = 1:length(subjids)
    [~, ~, div] = getBCIFilesForSubjid(subjids{c});
    
    load(['AllPower.m.cache\' subjids{c} '.mat'], 'targetCodes', 'resultCodes');

    up = 1;
    down = 2;
    
    upresult = resultCodes(targetCodes == up) == up;
    downresult = resultCodes(targetCodes == down) == down;

    figure;
    colormap('gray');

    subplot(121);
    sz = floor(length(upresult)/5);
    imagesc(repmat(upresult, 1, sz));
    axis equal;% axis off;
%     set(gca, 'FontSize', 24);
    
    subplot(122);
    sz = floor(length(downresult)/5);
    imagesc(repmat(downresult, 1, sz));
    axis equal;% axis off;
%     set(gca, 'FontSize', 24);
    
    mtit(subjids{c});
    
    SaveFig(fullfile(pwd, 'figs'), ['perf.' subjids{c}], 'eps');
end
