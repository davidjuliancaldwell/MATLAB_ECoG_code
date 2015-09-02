
%% First, build the meta file data for each of the subjects of interest
B_BuildFileMetaData;

%% Now, label bad channels and epochs
D_RawInspect;

% Collect all of the data in to a manageable format and preprocess
E_EpochCollectProcessed;

%% Then, perform analyses


%% Generate figures