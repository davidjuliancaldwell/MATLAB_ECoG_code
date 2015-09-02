%% analysis looking at power changes in control electrode on subject by
%% subject basis

% common across all remote areas analysis scripts
subjects = {
    '26cb98'
    '04b3d5'
    '38e116'
    '4568f4'
    '30052b'
    'fc9643'
    'mg'
    };

points = [
    80
    46
    26
    47
    53
    57
    41
    ];

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

% mean(points)

for c = 1:length(subjects)
    load(['AllPower.m.cache\' subjects{c} '.mat']);

    up = 1;
    down = 2;

    % do stuff
    
%     %OPTION 1, show when the powers separate,
%     % this was determined by looking at the running standard deviation
%     % and determining when the user separated up and down states
%     % 'dependably'
%     
%     smoothUp = GaussianSmooth(epochZs(controlChannel, targetCodes == up), 10)';
%     smoothDown = GaussianSmooth(epochZs(controlChannel, targetCodes == down), 10)';
%     
%     smoothUpStd = runningSD(epochZs(controlChannel, targetCodes == up), 10);
%     smoothDownStd = runningSD(epochZs(controlChannel, targetCodes == down), 10);
%     
%     ups = find(targetCodes == up);
%     downs = find(targetCodes == down);
% 
%     figure;
%     plot(ups, epochZs(controlChannel, targetCodes == up), 'r.', 'MarkerSize', 15); hold on;
%     plot(ups, smoothUp, 'r', 'LineWidth', 2); hold on;
%     plot(ups, smoothUp+smoothUpStd, 'r:', 'LineWidth', 2);
%     plot(ups, smoothUp-smoothUpStd, 'r:', 'LineWidth', 2);
%     
%     plot(ups, epochZs(controlChannel, targetCodes == down), 'b.', 'MarkerSize', 15); hold on;
%     plot(downs, smoothDown, 'b', 'LineWidth', 2);
%     plot(downs, smoothDown+smoothDownStd, 'b:', 'LineWidth', 2);
%     plot(downs, smoothDown-smoothDownStd, 'b:', 'LineWidth', 2);
%     
%     plot([points(c), points(c)], [-1 4], 'k', 'LineWidth', 2);
% 
%     % end OPTION 1
    
    preCodes = targetCodes(1:points(c));
    postCodes = targetCodes(points(c)+1:end);
    
    preZs = epochZs(:, 1:points(c));
    postZs = epochZs(:, points(c)+1:end);
    
    preupZs = preZs(:, preCodes == up);
    predownZs = preZs(:, preCodes == down);
    
    postupZs = postZs(:, postCodes == up);
    postdownZs = postZs(:, postCodes == down);

    [allrsas, allh] = signedSquaredXCorrValue(postZs, preZs, 2, 0.05/size(epochZs,1));
    allrsas(allh == 0) = NaN;
    
    [uprsas, uph] = signedSquaredXCorrValue(postupZs, preupZs, 2, 0.05/size(epochZs,1));
    uprsas(uph == 0) = NaN;
    
    [downrsas, downh] = signedSquaredXCorrValue(postdownZs, predownZs, 2, 0.05/size(epochZs,1));
    downrsas(downh == 0) = NaN;

%     % OPTION 2 - plot everything on individual brains
%     % plot for this subject, 3x2, on subject brain
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
%     mtit(sprintf('pre vs post %s - control Grid(%d)', subjects{c}, controlChannel));
% 
%     clearvars -except c subjects points;
% %     end OPTION 2

    % OPTION 3 - plot everything on the talairach brain
    
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

    clearvars -except c subjects allrsas_vals allrsas_locs uprsas_vals uprsas_locs downrsas_vals downrsas_locs points;
    % end OPTION 3
end
 
% in the case of OPTION 3

for c = 1:3
    switch(c)
        case 1
            locs = allrsas_locs; vals = allrsas_vals;
            title = 'all target pre vs post';
        case 2
            locs = uprsas_locs; vals = uprsas_vals;
            title = 'up target pre vs post';
        case 3
            locs = downrsas_locs; vals = downrsas_vals;
            title = 'down target pre vs post';
    end
    
    locs(:,1) = abs(locs(:,1));
    
    load('recon_colormap');
    
    figure;
    subplot(211);
    PlotDotsDirect('tail', locs, vals, 'both', [-1 1], 15, 'recon_colormap', [], false);
    view(90,0);
    colormap(cm);
    colorbar;

    subplot(212);
    PlotDotsDirect('tail', locs, vals, 'both', [-1 1], 10, 'recon_colormap', [], false);
    view(270,0);
    colormap(cm);
    colorbar;
    
    mtit(title);
end
% end OPTION 3

%     % store for later
%     
%     % in all 7 cases, the Grid is the first element in the montage, and
%     % we're recording in order 1:N
%     dists = findGridDistances(controlChannel, 1:Montage.Montage(1), 8, Montage.Montage(1)/8);
%     udists = unique(dists);
%     
%     % find the mean up target power and down target power (relative to
%     % rest, obviously)
% %     dists = findGridDistances(controlChannel, 1:64, 8, 8)


