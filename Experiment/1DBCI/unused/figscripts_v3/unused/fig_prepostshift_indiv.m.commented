%% analysis looking at power changes in all electrodes on subject by
%% subject basis as well as plotting them all on the talairach brain

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

analysisType = 2;
  % possible values
  % 1 = RSA analysis
  % 2 = difference in mean Z score
  
% allprezs = [];
% allpostzs = [];
allrsas_vals = [];
allrsas_locs = [];
allbareas = [];
allfareas = [];

% upprezs = [];
% uppostzs = [];
uprsas_vals = [];
uprsas_locs = [];
upbareas = [];
upfareas = [];

% downprezs = [];
% downpostzs = [];
downrsas_vals = [];
downrsas_locs = [];
downbareas = [];
downfareas = [];

for c = 6%1:length(subjids)
    subjid = subjids{c};
    [~, ~, div] = getBCIFilesForSubjid(subjids{c});
    
    load(['AllPower.m.cache\' subjids{c} '.mat']);
    
    up = 1;
    down = 2;

    % do stuff
    
    % this section is used for OPTION 2 and OPTION 3
    preCodes = targetCodes(1:div);
    postCodes = targetCodes(div+1:end);
    
    preZs = epochZs(:, 1:div);
    postZs = epochZs(:, div+1:end);
    
    preupZs = preZs(:, preCodes == up);
    predownZs = preZs(:, preCodes == down);
    
    postupZs = postZs(:, postCodes == up);
    postdownZs = postZs(:, postCodes == down);
        
    switch(analysisType)
        case 1
            [allrsas, allh] = signedSquaredXCorrValue(postZs, preZs, 2, 0.05/size(epochZs,1));    
            [uprsas, uph] = signedSquaredXCorrValue(postupZs, preupZs, 2, 0.05/size(epochZs,1));
            [downrsas, downh] = signedSquaredXCorrValue(postdownZs, predownZs, 2, 0.05/size(epochZs,1));
        case 2
            allrsas = mean(postZs,2)-mean(preZs,2);
%             allh = ones(size(epochZs,1),1) == 1;
            allh = (ttest2(postZs', preZs', 0.05/size(epochZs,1)) == 1);

            uprsas = mean(postupZs,2)-mean(preupZs,2);
%             uph = ones(size(epochZs,1),1) == 1;
            uph = (ttest2(postupZs', preupZs', 0.05/size(epochZs,1)) == 1);

            downrsas = mean(postdownZs,2)-mean(predownZs,2);
%             downh = ones(size(epochZs,1),1) == 1;
            downh = (ttest2(postdownZs', predownZs', 0.05/size(epochZs,1)) == 1);
    end

    trodeLocations = trodeLocsFromMontage(subjid, Montage);
    
% %     % collect trode locations in subject space
%     load([getSubjDir(subjids{c}) 'trodes.mat']);
%     trodeLocations = [];
%     
%     for electrodeElt = Montage.MontageTokenized
%         temp = electrodeElt{:};
%         
%         [st, en] = regexp(temp, '\([0-9]*:[0-9]*\)');
%         if (~isempty(st))
%             temp = [temp(1:en-1) ', :' temp(en:end)];
%             
%         end
%         eval(sprintf('trodeLocations = [trodeLocations; %s];', temp));
%     end
%     
 
    

%     % prune out insignificant electrodes and store for later
    allrsas_vals = cat(1, allrsas_vals, allrsas(allh == 1));
    allrsas_locs = cat(1, allrsas_locs, trodeLocations(allh == 1, :));
%     allareas     = cat(1, allareas, montageAreas(allh == 1));
%     
    uprsas_vals = cat(1, uprsas_vals, uprsas(uph == 1));
    uprsas_locs = cat(1, uprsas_locs, trodeLocations(uph == 1, :));
%     upareas     = cat(1, upareas, montageAreas(uph == 1));
%     
    downrsas_vals = cat(1, downrsas_vals, downrsas(downh == 1));
    downrsas_locs = cat(1, downrsas_locs, trodeLocations(downh == 1, :));
%     downareas     = cat(1, downareas, montageAreas(downh == 1));

%     clearvars -except c subjids allrsas_vals allrsas_locs uprsas_vals uprsas_locs downrsas_vals downrsas_locs allareas upareas downareas;
end

%%

load('recon_colormap');

figure;
PlotDotsDirect(subjid, trodeLocations(allh==1,:), allrsas(allh==1), 'r', [-2 2], 10, 'recon_colormap', [], false);
colormap(cm);
colorbar;

figure;
PlotDotsDirect(subjid, trodeLocations(uph==1,:), uprsas(uph==1), 'r', [-2 2], 10, 'recon_colormap', [], false);
colormap(cm);
colorbar;

figure;
PlotDotsDirect(subjid, trodeLocations(downh==1,:), downrsas(downh==1), 'r', [-2 2], 10, 'recon_colormap', [], false);
colormap(cm);
colorbar;

