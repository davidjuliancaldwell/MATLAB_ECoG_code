%% analysis looking at power changes in all electrodes on subject by
%% subject basis or on an as group basis

% common across all remote areas analysis scripts
subjects = {
    '04b3d5'
    '26cb98'
    '38e116'
    '4568f4'
    '30052b'
    'fc9643'
    'mg'
    };


% uncomment this following section if you're plotting significant power
% changes on the talairach brain all at once.  If you're plotting on
% subject specific brains, leave commented
allrsas_vals = [];
allrsas_locs = [];
uprsas_vals = [];
uprsas_locs = [];
downrsas_vals = [];
downrsas_locs = [];
% end section
% 
for c = 6% 1:length(subjects)
    load(['AllPower.m.cache\' subjects{c} '.mat']);

    up = 1;
    down = 2;

    % do stuff
    upes = epochZs(:, targetCodes == up);
    downes = epochZs(:, targetCodes == down);    
    rs = restZs(:, :);
    
    [allrsas, allh] = signedSquaredXCorrValue(epochZs, restZs, 2, 0.05/size(epochZs,1));
    allrsas(allh == 0) = NaN;
    
    [uprsas, uph] = signedSquaredXCorrValue(upes, restZs, 2, 0.05/size(epochZs,1));
    uprsas(uph == 0) = NaN;
    
    [downrsas, downh] = signedSquaredXCorrValue(downes, restZs, 2, 0.05/size(epochZs,1));
    downrsas(downh == 0) = NaN;

    % OPTION 1 - plot everything on individual brains
    % plot for this subject, 3x2, on subject brain
%     figure;
%     subplot(321);
%     PlotDots(subjects{c}, Montage.MontageTokenized, allrsas, side, [-1 1], 20, 'jet');
%     view(90,0);
%     colorbar;
%     title('all tgts');
%     subplot(322);
%     PlotDots(subjects{c}, Montage.MontageTokenized, allrsas, side, [-1 1], 20, 'jet');
%     view(270,0);
%     colorbar;
%     title('all tgts');
%     
%     subplot(323);
%     PlotDots(subjects{c}, Montage.MontageTokenized, uprsas, side, [-1 1], 20, 'jet');
%     view(90,0);
%     colorbar;
%     title('up tgts');
%     subplot(324);
%     PlotDots(subjects{c}, Montage.MontageTokenized, uprsas, side, [-1 1], 20, 'jet');
%     view(270,0);
%     colorbar;
%     title('up tgts');
% 
%     subplot(325);
%     PlotDots(subjects{c}, Montage.MontageTokenized, downrsas, side, [-1 1], 20, 'jet');
%     view(90,0);
%     colorbar;
%     title('down tgts');
%     subplot(326);
%     PlotDots(subjects{c}, Montage.MontageTokenized, downrsas, side, [-1 1], 20, 'jet');
%     view(270,0);
%     colorbar;
%     title('down tgts');
% 
%     mtit(sprintf('%s - control Grid(%d)', subjects{c}, controlChannel));

%     clearvars -except c subjects;
%     % end OPTION 1

    % OPTION 2 - plot everything on the talairach brain
    
    % collect trode locations in talairach space
    load([getSubjDir(subjects{c}) 'tail_trodes.mat']);
    trodeLocations = [];
    
    for electrodeElt = Montage.MontageTokenized
        temp = electrodeElt{:};
        
        [st, en] = regexp(temp, '\([0-9]*:[0-9]*\)');
        if (~isempty(st))
            temp = [temp(1:en-1) ', :' temp(en:end)];
            
        end
        eval(sprintf('trodeLocations = [trodeLocations; %s];', temp));
    end
    
    % prune out insignificant electrodes and store for later
    allrsas_vals = cat(1, allrsas_vals, allrsas(allh == 1));
    allrsas_locs = cat(1, allrsas_locs, trodeLocations(allh == 1, :));
    uprsas_vals = cat(1, uprsas_vals, uprsas(uph == 1));
    uprsas_locs = cat(1, uprsas_locs, trodeLocations(uph == 1, :));
    downrsas_vals = cat(1, downrsas_vals, downrsas(downh == 1));
    downrsas_locs = cat(1, downrsas_locs, trodeLocations(downh == 1, :));

    clearvars -except c subjects allrsas_vals allrsas_locs uprsas_vals uprsas_locs downrsas_vals downrsas_locs;
    % end OPTION 2
end

% in the case of OPTION 2
for c = 1:3
    switch(c)
        case 1
            locs = allrsas_locs; vals = allrsas_vals;
            title = 'all target activity';
        case 2
            locs = uprsas_locs; vals = uprsas_vals;
            title = 'up target activity';
        case 3
            locs = downrsas_locs; vals = downrsas_vals;
            title = 'down target activity';
    end
    
    figure;
    subplot(211);
    PlotDotsDirect('tail', locs, vals, 'both', [-1 1], 10, 'jet', [], false);
    view(90,0);
    colorbar;
    
    subplot(212);
    PlotDotsDirect('tail', locs, vals, 'both', [-1 1], 10, 'jet', [], false);
    view(270,0);
    colorbar;
    
    mtit(title);
end



