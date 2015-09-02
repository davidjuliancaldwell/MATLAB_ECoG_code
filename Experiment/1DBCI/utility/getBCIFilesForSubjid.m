function [files, side, div, sessions] = getBCIFilesForSubjid (subjid)

    if (strcmp(subjid, 'fc9643'))
        dsFile = fullfile('..', 'metadata', 'ds', 'fc9643_ud_mot_t_ds.mat');
        side = 'r';
        div = 48;%48;%53;%57;
        sessions = [1 1 1 2 2 3];
    elseif (strcmp(subjid, '26cb98'))
        dsFile = fullfile('..', 'metadata', 'ds', '26cb98_ud_im_t_ds.mat');
        side = 'r';
        div = 75;%75;%58;%80;
        sessions = [1 1 1 1 1];
    elseif (strcmp(subjid, '38e116'))
        dsFile = fullfile('..', 'metadata', 'ds', '38e116_ud_mot_h_ds.mat');
        side = 'r';
        div = 22;%21;%22;%26;
        sessions = [1 1 2];
    elseif (strcmp(subjid, '4568f4'))
        dsFile = fullfile('..', 'metadata', 'ds', '4568f4_ud_mot_t_ds.mat');
        side = 'r';
        div = 53;%52;%54;%47;
        sessions = [1 1 1 2 2 2];
    elseif (strcmp(subjid, '30052b'))
        dsFile = fullfile('..', 'metadata', 'ds', '30052b_ud_im_t_ds.mat');
        side = 'r';
        div = 32;%32;%33;%53;
        sessions = [1 1 2 2 3 3 3 3 3 3 4];
    elseif (strcmp(subjid, 'mg'))
        dsFile = fullfile('..', 'metadata', 'ds', 'mg_ud_im_t_ds.mat');
        side = 'both';
        div = 20;%42;%40;%41;
        sessions = [1 1 1 1 1 1];
    elseif (strcmp(subjid, '04b3d5'))
        dsFile = fullfile('..', 'metadata', 'ds', '04b3d5_ud_im_t_ds.mat');
        side = 'l';
        div = 40;%20;%40;%46;
        sessions = [1 1 2 2 3];
    else
        warning ('unknown subjid entered');
        files = {};
        side = '';
        return;
    end
    
    load(dsFile);
    files = extractFilesFromDataset(ds);
    
    assert(length(files) == length(sessions), 'number of sessions does not equal number of files, something is wrong');
end

function files = extractFilesFromDataset(ds)
    for c = 1:length(ds.recs)
        files{c} = fullfile(ds.recs(c).dir, ds.recs(c).file);
    end
end