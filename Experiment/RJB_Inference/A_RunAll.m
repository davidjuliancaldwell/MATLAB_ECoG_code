
%% First, build the meta file data for each of the subjects of interest
B_BuildFileMetaData;

%% Now, label bad channels and epochs
C_RawInspect;

% Collect all of the data in to a manageable format and preprocess
C_EpochCollectRaw;
C_EpochCollectProcessed;

%% Perform behavioral analyses
D_Behavioral;

%% Extract Epoch Averages and evaluate for interesting trends
E_ExtractEpochAverages;
E_EvaluateEpochAverages;

%% Perform classification analysis
F_ClassificationAnalysis;

%% Perform post-hoc biasing analyses
H_PostHocBias;
