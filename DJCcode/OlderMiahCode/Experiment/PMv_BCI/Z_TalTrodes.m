Z_Constants;

% SIDS = cat(2, SIDS, '7662c2');

addpath ./scripts;
addpath d:\dropbox\code\me\sandbox\talairach;

%%
bas = cell(size(SIDS));
hmats = cell(size(SIDS));

idx = 0;
for zid = SIDS
    sid = zid{:};
    idx = idx + 1;
   
    brodAreas = fullfile(getSubjDir(sid), 'other', 'brod_areas.mat');
    brodAlt   = fullfile(getSubjDir(sid), 'brod_areas.mat');
    
    brodExist = exist(brodAreas, 'file');
    brodAltExist = exist(brodAlt, 'file');
    
    areas = [];
    
    if (brodExist)
        load(brodAreas);
        go = true;
    elseif (brodAltExist)
        load(brodAlt);
        go = true;
    else
        % need to generate brodmann areas
        
        talTrodes = fullfile(getSubjDir(sid), 'other', 'tail_trodes.mat');
        talAlt    = fullfile(getSubjDir(sid), 'tail_trodes.mat');

        if (exist(talTrodes, 'file'))
            % do nothing
            go = true;
        elseif (exist(talAlt, 'file'))
            % do nothing
            go = true;
        else
            % need to generate talairach trodes
            fprintf('generating talairach trodes for %s\n', sid);            
            go = trodesToTalairach(sid) == 1;
%             go = false;
        end

        if (go)
            [~,~,~,Montage] = filesForSubjid(sid);
            locs = trodeLocsFromMontage(sid, Montage, true);

            % now generate brodmann areas
            fprintf('generating brodmann areas for %s\n', sid);
            areas = brodmannAreaForElectrodes(locs, true);
            
            save(brodAreas, 'areas');
        end
    end
    
    bas{idx} = areas;

    % hmat
    hmatAreas = fullfile(getSubjDir(sid), 'other', 'hmat_areas.mat');
    hmatAlt   = fullfile(getSubjDir(sid), 'hmat_areas.mat');
    
    hmatExist = exist(hmatAreas, 'file');
    hmatAltExist = exist(hmatAlt, 'file');
    
    areas = [];
    
    if (hmatExist)
        load(hmatAreas);
    elseif (hmatAltExist)
        load(hmatAlt);
    else
        if (go)
            [~,~,~,Montage] = filesForSubjid(sid);
            locs = trodeLocsFromMontage(sid, Montage, true);

            % now generate hmat areas
            fprintf('generating hmat areas for %s\n', sid);
            [areas, key] = hmatValue(locs);
            
            save(hmatAreas, 'areas', 'key');            
        end
    end
    hmats{idx} = areas;    
end

save(fullfile(META_DIR, 'areas.mat'), 'bas', 'hmats', 'key');

%% check to see which subjects we can use

viable = false(size(SIDS));
trodesOfInterest= {};

% hmatsWeLike = [5 6 7 8]; SMA
hmatsWeLike = [11 12]; % PMv
% hmatsWeLike = [9 10]; % PMd
% basWeLike = [9 45 46]; % pfc

for idx = 1:length(viable)
    test = ismember(hmats{idx}, hmatsWeLike);
%     test = ismember(bas{idx}, basWeLike);
    
    if (any(test))
        viable(idx) = true;
        trodesOfInterest{idx} = find(test);
%         trodesOfInterest{idx} = find(ismember(hmats{idx}, hmatsWeLike));
%         trodesOfInterest{idx} = find(ismember(bas{idx}, basWeLike)');
    else
        warning(sprintf('%s has no valid electrodes', SIDS{idx}));
    end
end

save(fullfile(META_DIR, 'areas.mat'), '-append', 'trodesOfInterest');
