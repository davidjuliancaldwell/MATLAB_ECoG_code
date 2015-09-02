% First, build the meta file data for each of the subjects of interest
B_BuildFileMetaData;

% Collect all of the data in to a manageable format and preprocess
C_EpochCollect;

% Perform behavioral analyses, this includes
%  - Overall performance trends
D_Behavioral;

% Look at the error related neural responses
% - compare mean neural activation during pre phase and fb phase
% - generate features for simple classification analyses
E_EpochPowerAnalysis;
E_EpochPowerAnalysis_Plots;

% Perform a basic classification analysis
F_ClassificationAnalysis;