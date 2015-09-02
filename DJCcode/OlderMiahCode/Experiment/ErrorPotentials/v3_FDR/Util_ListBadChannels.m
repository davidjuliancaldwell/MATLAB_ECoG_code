
% subjid = '38e116';
% [odir, hemi, bads, ~, files2] = ErrorPotentialsDataFiles('38e116', 2);
% [~,    ~,    ~,    ~, files3] = ErrorPotentialsDataFiles('38e116', 3);
% [~,    ~,    ~,    ~, files5] = ErrorPotentialsDataFiles('38e116', 5);
% [~,    ~,    ~,    ~, files6] = ErrorPotentialsDataFiles('38e116', 6);
% [~,    ~,    ~,    ~, files7] = ErrorPotentialsDataFiles('38e116', 7);
% ftemp = cat(2, files2{1}, files3{1}, files5{1}, files6{1}, files7{1});

% subjid = 'fc9643';
% [odir, hemi, bads, ~, files2] = ErrorPotentialsDataFiles('fc9643', 2);
% [~,    ~,    ~,    ~, files3] = ErrorPotentialsDataFiles('fc9643', 3);
% [~,    ~,    ~,    ~, files5] = ErrorPotentialsDataFiles('fc9643', 5);
% ftemp = cat(2, files2{1}, files3{1}, files5{1});

subjid = '9ad250';
[odir, hemi, bads, ~, files2] = ErrorPotentialsDataFiles(subjid, 2);
ftemp = files2{1};

% subjid = '4568f4';
% [odir, hemi, bads, ~, files2] = ErrorPotentialsDataFiles(subjid, 2);
% ftemp = files2{1};

% subjid = '30052b';
% [odir, hemi, bads, ~, files2] = ErrorPotentialsDataFiles(subjid, 2);
% ftemp = files2{1};

%%
bads = [];

for mfile = ftemp

    fprintf('working file %s\n', mfile{:});

    
    % load a file
    load(strrep(mfile{:}, '.dat', '_montage.mat'));
    bads = union(Montage.BadChannels, bads);
    
end

bads


