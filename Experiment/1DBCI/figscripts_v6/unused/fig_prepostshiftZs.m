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

allprezs = [];
allpostzs = [];
allareas = [];

upprezs = [];
uppostzs = [];
upareas = [];

downprezs = [];
downpostzs = [];
downareas = [];


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

    allhs = ttest(epochZs',0,0.05/size(epochZs,1));
    allhs = allhs == 1;
    
    uphs  = ttest(epochZs(:, targetCodes==up)', 0, 0.05/size(epochZs,1));
    uphs = uphs == 1;
    
    downhs = ttest(epochZs(:, targetCodes==down)', 0, 0.05/size(epochZs,1));
    downhs = downhs == 1;
    
    
%     hs = allhs==1 | uphs==1 | downhs==1;
    
%     [allrsas, allh] = signedSquaredXCorrValue(postZs, preZs, 2, 0.05/size(epochZs,1));
%     
%     [uprsas, uph] = signedSquaredXCorrValue(postupZs, preupZs, 2, 0.05/size(epochZs,1));
%     
%     [downrsas, downh] = signedSquaredXCorrValue(postdownZs, predownZs, 2, 0.05/size(epochZs,1));

    
    % collect trode locations in talairach space
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
    %  - this is currently assuming that all electrodes were recorded.
    %  this is wrong.
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
    
    allprezs = cat(1, allprezs, mean(preZs(allhs,:),2));
    allpostzs = cat(1, allpostzs, mean(postZs(allhs,:),2));
    allareas = cat(1, allareas, montageAreas(allhs));

    upprezs = cat(1, upprezs, mean(preupZs(uphs,:),2));
    uppostzs = cat(1, uppostzs, mean(postupZs(uphs,:),2));
    upareas = cat(1, downareas, montageAreas(uphs));
    
    downprezs = cat(1, downprezs, mean(predownZs(downhs,:),2));
    downpostzs = cat(1, downpostzs, mean(postdownZs(downhs,:),2));
    downareas = cat(1, downareas, montageAreas(downhs));
    
%     % prune out insignificant electrodes and store for later
%     allrsas_vals = cat(1, allrsas_vals, allrsas(allh == 1));
%     allrsas_locs = cat(1, allrsas_locs, trodeLocations(allh == 1, :));
%     allareas     = cat(1, allareas, montageAreas(allh == 1));
%     
%     uprsas_vals = cat(1, uprsas_vals, uprsas(uph == 1));
%     uprsas_locs = cat(1, uprsas_locs, trodeLocations(uph == 1, :));
%     upareas     = cat(1, upareas, montageAreas(uph == 1));
%     
%     downrsas_vals = cat(1, downrsas_vals, downrsas(downh == 1));
%     downrsas_locs = cat(1, downrsas_locs, trodeLocations(downh == 1, :));
%     downareas     = cat(1, downareas, montageAreas(downh == 1));

%     clearvars -except c subjids allrsas_vals allrsas_locs uprsas_vals uprsas_locs downrsas_vals downrsas_locs allareas upareas downareas;
end
 


%% make some bar plots based on brodmann areas generated from talairach
%% transformation
% order of idxs: M1/S1 PPC PM PFC

allIdxs = {
    find(allareas == 1 | allareas == 2 | allareas == 3 | allareas == 4),
    find(allareas == 7),
    find(allareas == 6),
    find(allareas == 9 | allareas == 46)
    };

upIdxs = {
    find(upareas == 1 | upareas == 2 | upareas == 3 | upareas == 4),
    find(upareas == 7),
    find(upareas == 6),
    find(upareas == 9 | upareas == 46)
    };

downIdxs = {
    find(downareas == 1 | downareas == 2 | downareas == 3 | downareas == 4),
    find(downareas == 7),
    find(downareas == 6),
    find(downareas == 9 | downareas == 46)
    };

%%

for c = 1:3
    switch(c)
        case 1
            idxs = allIdxs; 
            prezs = allprezs;
            postzs = allpostzs;
            tit = 'all target pre vs post'; direction = 'all';
        case 2
            idxs = upIdxs; 
            prezs = upprezs;
            postzs = uppostzs;
            tit = 'up target pre vs post'; direction = 'up';
        case 3
            idxs = downIdxs; 
            prezs = downprezs;
            postzs = downpostzs;
            tit = 'down target pre vs post'; direction = 'down';
    end
    
    avs = zeros(length(idxs), 1);
    ers = zeros(length(idxs), 1);
    
    for d = 1:length(idxs)
        if (~isempty(idxs{d}))
            pre_avs(d) = mean(prezs(idxs{d}));
            pre_ers(d) = std(prezs(idxs{d}))/sqrt(length(idxs{d}));
            post_avs(d) = mean(postzs(idxs{d}));
            post_ers(d) = std(postzs(idxs{d}))/sqrt(length(idxs{d}));
        else
            pre_avs(d) = 0;
            post_ers(d) = 0;
        end
    end
    
    figure;
    
    barweb([pre_avs;post_avs]', [pre_ers;post_ers]', [] ,{'M1/S1 (BA1-4)', 'PPC (BA7)', 'PM (BA6)', 'PFC (BA9, BA46)'}, tit, 'Est. Cortical Area', 'mean task Z', ...
        [], [], {'pre' 'post'});    
    
%     barweb([avs,avs], [ers,ers], [], ['a' 'b'], tit, 'Est. Cortical Area', 'signed r^2', ...
%         [], [], {'M1/S1 (BA1-4)', 'PPC (BA7)', 'PM (BA6)', 'PFC (BA9, BA46)'});
    
    hgsave(fullfile(pwd, 'figs', sprintf('prepostshift.bar.%s.fig',direction)));
    SaveFig(fullfile(pwd, 'figs'), sprintf('prepostshift.bar.%s',direction));
end


