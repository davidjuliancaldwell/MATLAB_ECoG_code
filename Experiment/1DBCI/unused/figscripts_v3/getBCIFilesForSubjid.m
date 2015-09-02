function [files, side, div] = getBCIFilesForSubjid (subjid)

    if (strcmp(subjid, '26cb98'))
        dsFile = '../ds/26cb98_ud_im_t_ds.mat';
        side = 'r';
        div = 75;%75;%58;%80;
    elseif (strcmp(subjid, '04b3d5'))
        dsFile = '../ds/04b3d5_ud_im_t_ds.mat';
        side = 'l';
        div = 40;%20;%40;%46;
    elseif (strcmp(subjid, '38e116'))
        dsFile = '../ds/38e116_ud_mot_h_ds.mat';
        side = 'r';
        div = 22;%21;%22;%26;
    elseif (strcmp(subjid, '4568f4'))
        dsFile = '../ds/4568f4_ud_mot_t_ds.mat';
        side = 'r';
        div = 53;%52;%54;%47;
    elseif (strcmp(subjid, '30052b'))
        dsFile = '../ds/30052b_ud_im_t_ds.mat';
        side = 'r';
        div = 32;%32;%33;%53;
    elseif (strcmp(subjid, 'fc9643'))
        dsFile = '../ds/fc9643_ud_mot_t_ds.mat';
        side = 'r';
        div = 48;%48;%53;%57;
    elseif (strcmp(subjid, 'mg'))
        dsFile = '../ds/mg_ud_im_t_ds.mat';
        side = 'both';
        div = 20;%42;%40;%41;
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