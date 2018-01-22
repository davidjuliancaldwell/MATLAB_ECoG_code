function generateTalSpaceTrodesAndLabels_func(sid)
    %% generate the talairach transformed electrode positions
    trodesToTalairach(sid);

    %% generate the hmat values for electrodes
    load(fullfile(getSubjDir(sid), 'other', 'tail_trodes.mat'));
    [areas, key] = hmatValueForElectrodes(AllTrodes);
    save(fullfile(getSubjDir(sid), 'other', 'hmat_areas.mat'), 'areas', 'key');

    h = fopen(fullfile(getSubjDir(sid), 'other', 'hmat_areas.txt'), 'w');
    fprintf(h, 'HMAT_%d\n', areas);
    fclose(h);

    %% generate brodmann areas for electrodes
    RUN_LOCAL = false;

    if (RUN_LOCAL)
        warning 'running using local tal daemon';
    end
    
    areas = brodmannAreaForElectrodes(AllTrodes, RUN_LOCAL);
    save(fullfile(getSubjDir(sid), 'other', 'brod_areas.mat'), 'areas');

    h = fopen(fullfile(getSubjDir(sid), 'other', 'brod_areas.txt'), 'w');
    fprintf(h, 'BRODMANN_%d\n', areas);
    fclose(h);
end