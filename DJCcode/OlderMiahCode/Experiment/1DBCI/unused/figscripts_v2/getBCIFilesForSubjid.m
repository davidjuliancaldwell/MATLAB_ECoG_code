function [files, side, div] = getBCIFilesForSubjid (subjid)

    if (strcmp(subjid, '26cb98'))
        dsFile = '../metadata/ds/26cb98_ud_im_t_ds.mat';
        side = 'r';
        div = 58;%80;
    elseif (strcmp(subjid, '38e116'))
        dsFile = '../metadata/ds/38e116_ud_mot_h_ds.mat';
        side = 'r';
        div = 22;%26;
    elseif (strcmp(subjid, '4568f4'))
        dsFile = '../metadata/ds/4568f4_ud_mot_t_ds.mat';
        side = 'r';
        div = 54;%47;
    elseif (strcmp(subjid, '30052b'))
        dsFile = '../metadata/ds/30052b_ud_im_t_ds.mat';
        side = 'r';
        div = 33;%53;
    elseif (strcmp(subjid, 'fc9643'))
        dsFile = '../metadata/ds/fc9643_ud_mot_t_ds.mat';
        side = 'r';
        div = 53;%57;
    elseif (strcmp(subjid, 'mg'))
        dsFile = '../metadata/ds/mg_ud_im_t_ds.mat';
        side = 'both';
        div = 40;%41;
    elseif (strcmp(subjid, '04b3d5'))
        dsFile = '../metadata/ds/04b3d5_ud_im_t_ds.mat';
        side = 'l';
        div = 40;%46;
    else
        warning ('unknown subjid entered');
        files = {};
        side = '';
        return;
    end
    
    load(dsFile);
    files = extractFilesFromDataset(ds);
    
end

function files = extractFilesFromDataset(ds)
    for c = 1:length(ds.recs)
        files{c} = fullfile(ds.recs(c).dir, ds.recs(c).file);
    end
end