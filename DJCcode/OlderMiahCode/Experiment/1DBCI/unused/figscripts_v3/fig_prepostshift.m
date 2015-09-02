%% analysis looking at power changes in all electrodes on subject by
%% subject basis as well as plotting them all on the talairach brain

% common across all remote areas analysis scripts
fig_setup;

analysisType = 2;
  % possible values
  % 1 = RSA analysis
  % 2 = difference in mean Z score
  
allrsas_vals = [];
allrsas_locs = [];
allbareas = [];
allfareas = [];

uprsas_vals = [];
uprsas_locs = [];
upbareas = [];
upfareas = [];

downrsas_vals = [];
downrsas_locs = [];
downbareas = [];
downfareas = [];

for c = 1:length(subjids)
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
            allh = (ttest2(postZs', preZs', 0.05/size(epochZs,1)) == 1);

            uprsas = mean(postupZs,2)-mean(preupZs,2);
            uph = (ttest2(postupZs', preupZs', 0.05/size(epochZs,1)) == 1);

            downrsas = mean(postdownZs,2)-mean(predownZs,2);
            downh = (ttest2(postdownZs', predownZs', 0.05/size(epochZs,1)) == 1);
    end
    
    allh(controlChannel) = 0;
    uph(controlChannel) = 0;
    downh(controlChannel) = 0;
    
%     % collect trode locations in talairach space
    load([getSubjDir(subjids{c}) 'tail_trodes.mat']);
    trodeLocations = [];
    
    for electrodeElt = Montage.MontageTokenized
        temp = electrodeElt{:};
        
        [st, en] = regexp(temp, '\([0-9]*:[0-9]*\)');
        if (~isempty(st))
            temp = [temp(1:en-1) ', :' temp(en:end)];
            
        end
        eval(sprintf('trodeLocations = [trodeLocations; %s];', temp));
    end
    
    % collect brodmann areas
    load(fullfile(getSubjDir(subjids{c}), 'brod_areas.mat'));
    
    montageAreas = [];
    
    for electrodeElt = Montage.MontageTokenized
        temp = electrodeElt{:};
        
        label = regexp(temp, '[A-Za-z]+', 'match');
        eval(sprintf('firstloc = %s(1, :);', label{:}));
        
        for d = 1:3
            locs{d} = find(AllTrodes(:,d)==firstloc(:,d));
        end
        
        loc = intersect(intersect(locs{1},locs{2}),locs{3});
        if (length(loc) ~= 1)
            warning('we have a problem');
            loc = loc(1);
        end
        
        eval(sprintf('numitems = size(%s,1);', label{:}));
        
        montageAreas = cat(1, montageAreas, areas(loc:(loc+numitems-1))');        
    end
    
    % collect functional areas
    %  - this is currently assuming that all electrodes were recorded.
    %  this is wrong.
    
    fAreas = [];
    
    for electrodeElt = Montage.MontageTokenized
        temp = electrodeElt{:};
        
        label = regexp(temp, '[A-Za-z]+', 'match');
        eval(sprintf('firstloc = %s(1, :);', label{:}));
        
        for d = 1:3
            locs{d} = find(AllTrodes(:,d)==firstloc(:,d));
        end
        
        loc = intersect(intersect(locs{1},locs{2}),locs{3});
        if (length(loc) ~= 1)
            warning('we have a problem');
            loc = loc(1);
        end
        
        eval(sprintf('numitems = size(%s,1);', label{:}));
        values = hmatValue(AllTrodes(loc:(loc+numitems-1),:));
        fAreas = cat(1, fAreas, values);        
    end
    
%     allprezs = cat(1, allprezs, mean(preZs(allhs,:),2));
%     allpostzs = cat(1, allpostzs, mean(postZs(allhs,:),2));
    allbareas = cat(1, allbareas, montageAreas(allh));
    allfareas = cat(1, allfareas, fAreas(allh));

%     upprezs = cat(1, upprezs, mean(preupZs(uphs,:),2));
%     uppostzs = cat(1, uppostzs, mean(postupZs(uphs,:),2));
    upbareas = cat(1, upbareas, montageAreas(uph));
    upfareas = cat(1, upfareas, fAreas(uph));
    
%     downprezs = cat(1, downprezs, mean(predownZs(downhs,:),2));
%     downpostzs = cat(1, downpostzs, mean(postdownZs(downhs,:),2));
    downbareas = cat(1, downbareas, montageAreas(downh));
    downfareas = cat(1, downfareas, fAreas(downh));
    
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
 

% %% make some bar plots based on brodmann areas generated from talairach
% %% transformation
% % order of idxs: M1/S1 PPC PM PFC
% 
% allIdxs = {
%     find(allareas == 1 | allareas == 2 | allareas == 3 | allareas == 4),
%     find(allareas == 7),
%     find(allareas == 6),
%     find(allareas == 9 | allareas == 46),
%     find(allareas ~= 1 | allareas ~= 2 | allareas ~= 3 | allareas ~= 4 | allareas ~= 7 | allareas ~= 6 | allareas ~= 9 | allareas ~= 46 | ~isnan(allareas))
%     };
% 
% upIdxs = {
%     find(upareas == 1 | upareas == 2 | upareas == 3 | upareas == 4),
%     find(upareas == 7),
%     find(upareas == 6),
%     find(upareas == 9 | upareas == 46),
%     find(upareas ~= 1 | upareas ~= 2 | upareas ~= 3 | upareas ~= 4 | upareas ~= 7 | upareas ~= 6 | upareas ~= 9 | upareas ~= 46 | ~isnan(upareas))
%     };
% 
% downIdxs = {
%     find(downareas == 1 | downareas == 2 | downareas == 3 | downareas == 4),
%     find(downareas == 7),
%     find(downareas == 6),
%     find(downareas == 9 | downareas == 46),
%     find(downareas ~= 1 | downareas ~= 2 | downareas ~= 3 | downareas ~= 4 | downareas ~= 7 | downareas ~= 6 | downareas ~= 9 | downareas ~= 46 | ~isnan(downareas))
%     };

% %% make some bar plots based on functional areas generated from hmat
% %% transformation
% % order of idxs: M1/S1
% 
% allIdxs = {
%     find(allareas == 1 | allareas == 2 | allareas == 3 | allareas == 4),
%     find(allareas == 5 | allareas == 6 | allareas == 7 | allareas == 8),
%     find(allareas == 9 | allareas == 10),
%     find(allareas == 11 | allareas == 12),
%     find(allareas == 0)
%     };
% 
% upIdxs = {
%     find(upareas == 1 | upareas == 2 | upareas == 3 | upareas == 4),
%     find(upareas == 5 | upareas == 6 | upareas == 7 | upareas == 8),
%     find(upareas == 9 | upareas == 10),
%     find(upareas == 11 | upareas == 12),
%     find(upareas == 0)
%     };
% 
% downIdxs = {
%     find(downareas == 1 | downareas == 2 | downareas == 3 | downareas == 4),
%     find(downareas == 5 | downareas == 6 | downareas == 7 | downareas == 8),
%     find(downareas == 9 | downareas == 10),
%     find(downareas == 11 | downareas == 12),
%     find(downareas == 0)
%     };

%% compount area estimation method based on brodmann areas (tal daemon) and
%% functional areas (hmat)
%% transformation
% order of idxs: M1/S1 PMd PMv BA8/9/46 PPC Other Fail

% %
% warning('super hack here - if you change anything about this script, double check this');
% downbareas(7) = 7;
% downbareas(11) = 46;
% allbareas(19) = 7;
% allbareas(28) = 46;
% % end

allIdxs = {
    find(allfareas == 1 | allfareas == 2 | allfareas == 3 | allfareas == 4)
    find(allfareas == 9 | allfareas == 10)
    find(allfareas == 11 | allfareas == 12)
    find(ismember(allbareas, [8 9 46]))
    find(allbareas == 7 | allbareas == 40)
    find(allfareas == 0 & ~ismember(allbareas, [8 9 46 7 40]) & ~isnan(allbareas))
    find(isnan(allbareas))
    };

upIdxs = {
    find(upfareas == 1 | upfareas == 2 | upfareas == 3 | upfareas == 4)
    find(upfareas == 9 | upfareas == 10)
    find(upfareas == 11 | upfareas == 12)
    find(ismember(upbareas, [8 9 46]))
    find(upbareas == 7 | upbareas == 40)
    find(upfareas == 0 & ~ismember(upbareas, [8 9 46 7 40]) & ~isnan(upbareas))
    find(isnan(upbareas))
    };

downIdxs = {
    find(downfareas == 1 | downfareas == 2 | downfareas == 3 | downfareas == 4)
    find(downfareas == 9 | downfareas == 10)
    find(downfareas == 11 | downfareas == 12)
    find(ismember(downbareas, [8 9 46]))
    find(downbareas == 7 | downbareas == 40)
    find(downfareas == 0 & ~ismember(downbareas, [8 9 46 7 40]) & ~isnan(downbareas))
    find(isnan(downbareas))
    };


%% do classification brain plots
for c = 1:3
    switch(c)
        case 1
            idxs = allIdxs; 
            vals = allrsas_vals;
            locs = allrsas_locs;
            tit = 'all target pre vs post'; direction = 'all';
        case 2
            idxs = upIdxs; 
            vals = uprsas_vals;
            locs = uprsas_locs;
            tit = 'up target pre vs post'; direction = 'up';
        case 3
            idxs = downIdxs;
            vals = downrsas_vals;
            locs = downrsas_locs;
            tit = 'down target pre vs post'; direction = 'down';
    end

    mylocs = [];
    myvals = [];
    
    for d = 1:length(idxs)
        if (~isempty(idxs{d}))
            mylocs = cat(1,mylocs,locs(idxs{d},:));
            myvals = cat(1,myvals,d*ones(size(idxs{d})));
        end
    end

    figure;
    
    % hack to make class failures go away
    myvals(myvals==7)=6; % they become "others"
    % end hack
    
    mylocs(:,1) = abs(mylocs(:,1)); % shift all electrodes over to one side of the brain
    
    PlotDotsDirect('tail',mylocs,myvals,'r',[min(myvals) max(myvals)], 10, 'recon_colormap', [], []); 
    title(sprintf('%s - electrode classification', tit));
    load('recon_colormap');
    colormap(cm);
    
    % continue hack
%     cb = colorbar('YTickLabel', {'M1/S1', 'PMd', 'PMv', 'BA 8/9/46',
%     'PPC', 'Other', 'class failure'}, 'YTick', 1:7);
    cb = colorbar('YTickLabel', {'M1/S1', 'PMd', 'PMv', 'BA 8/9/46', 'PPC', 'Other'}, 'YTick', 1:6);
    % end continue hack
    
    set(cb, 'YTickMode', 'manual');
%     SaveFig(figOutDir, sprintf('prepostshift.class.%s',direction), 'png');    
end

%% do difference brain plots
for c = 1%:3
    switch(c)
        case 1
            idxs = allIdxs; 
            vals = allrsas_vals;
            locs = allrsas_locs;
            tit = 'all target pre vs post'; direction = 'all';
        case 2
            idxs = upIdxs; 
            vals = uprsas_vals;
            locs = uprsas_locs;
            tit = 'up target pre vs post'; direction = 'up';
        case 3
            idxs = downIdxs;
            vals = downrsas_vals;
            locs = downrsas_locs;
            tit = 'down target pre vs post'; direction = 'down';
    end

%     mylocs = [];
%     myvals = [];
%     
%     for d = 1:length(idxs)
%         if (~isempty(idxs{d}))
%             mylocs = cat(1,mylocs,locs(idxs{d},:));
%             myvals = cat(1,myvals,d*ones(size(idxs{d})));
%         end
%     end

    figure;
    
    locs(:,1) = abs(locs(:,1)); % shift all electrodes over to one side of the brain
    
%     return;
%     shaded_brain;
    
    PlotDotsDirect('tail',locs,vals,'r',[-max(abs(vals)) max(abs(vals))], 10, 'recon_colormap', [], []); 
    title(sprintf('%s', tit));
    load('recon_colormap');
    colormap(cm);
    colorbar;
%     cb = colorbar('YTickLabel', {'M1/S1', 'PMd', 'PMv', 'BA 8/9/45/46', 'PPC', 'Other', 'class failure'}, 'YTick', 1:7);
    
%     set(cb, 'YTickMode', 'manual');
%     SaveFig(figOutDir, sprintf('prepostshift.tal.%s',direction), 'png');    
end

%% do bar plots

for c = 1%:3
    switch(c)
        case 1
            idxs = allIdxs; 
            vals = allrsas_vals;
            tit = 'all target pre vs post'; direction = 'all';
        case 2
            idxs = upIdxs; 
            vals = uprsas_vals;
            tit = 'up target pre vs post'; direction = 'up';
        case 3
            idxs = downIdxs;
            vals = downrsas_vals;
            tit = 'down target pre vs post'; direction = 'down';
    end
       
    for d = 1:length(idxs)-2
        lens(d) = length(idxs{d});
    end
    
    long = max(lens);
    
    avs = zeros(length(idxs)-2, long);
%     ers = zeros(length(idxs), long);
    
%     avs = zeros(length(idxs), 1);
%     ers = zeros(length(idxs), 1);
    
    for d = 1:length(idxs)-2
        if (~isempty(idxs{d}))
            avs(d, 1:length(idxs{d})) = vals(idxs{d});
            
%             pre_avs(d) = mean(prezs(idxs{d}));
%             pre_ers(d) = std(prezs(idxs{d}))/sqrt(length(idxs{d}));
%             post_avs(d) = mean(postzs(idxs{d}));
%             post_ers(d) = std(postzs(idxs{d}))/sqrt(length(idxs{d}));
%         else
%             pre_avs(d) = 0;
%             post_ers(d) = 0;
        end
    end
    
    figure;
    
    switch(analysisType)
        case 1
            yinfo = 'pre-post RSA'
        case 2
            yinfo = 'E(z_p_o_s_t) - E(z_p_r_e)';
    end
    
    load('recon_colormap');
    divs = size(avs,1);
    step = floor((size(cm,1)-1)/divs);
    colors(1,:) = cm(1,:);
    
    cnt = 1;
    for z = 1+step:step:size(cm,1)
        cnt = cnt+1;
        colors(cnt,:) = cm(z,:);
    end
        
    allavs = [];
    allcolors = [];
    
    for z = 1:size(avs,1)
        temp = avs(z,:);
        temp(temp==0) = [];
        temp(end+1) = 0;
        
        allavs = cat(2, allavs, temp);
        allcolors = cat(1, allcolors, repmat(colors(z,:),length(temp),1));
    end
    
    barWithControl(allavs, allcolors);
    title(tit);
    
    set(gca,'GridLineStyle','none')
    set(gcf,'Color',[1 1 1]);
    set(gca,'YTick',[])
    % the new way using barWithControl
    
    % the old way, using barweb
%     h = barweb(avs, zeros(size(avs)), 1, {'M1/S1', 'PMd', 'PMv', 'BA 8/9/46', 'PPC'}, tit, ...
%         'Est. Cortical Area', yinfo, [], [], []);    
%             
%     SaveFig(figOutDir, sprintf('prepostshift.bar.%s',direction), 'eps');
end


