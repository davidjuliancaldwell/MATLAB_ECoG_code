Z_Constants;
addpath ./scripts;
addpath d:\dropbox\code\me\sandbox\talairach;

SIDS{1} = [];

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
