% First, build the meta file data for each of the subjects of interest
B_BuildFileMetaData;

% Collect all of the data in to a manageable format and preprocess
C_EpochCollect;

% Perform behavioral analyses, this includes
%  - Overall performance trends
%  - Assessment of whether one trial type was more difficult for a subject
%    than another trial type
%  - Labeling failures in terms of severity (i.e. final distance from
%    target)
%  - Construction of outcome probability maps
D_Behavioral;

% Look at the error related neural responses
%  - Most basically, the time series of successful and failed trials
%  - As well as plots on brains showing mean activation by band before and
%    after trial end
%  - Stratify these values by error severity (after trial end)
%  - Or correlate with outcome probability (before trial end)
E_DoSimpleNeuralAnalyses;

%  - Then stratified by error severity
%  - Correlated with outcome probability
%  - If there is a "failure recognition point", look at the time series
%    synched on this point. Especially focusing on what synchronizing on
%    this time period does for the ERPs.

%  - Extract features to be used in classification analyses
%  - Do errors become more prevalent with experience (time)?

% Perform single trial classification analyses
%  - Predicting pending trial failure
%  - Predicting occured trial failure