% before running any scripts, it's important to make sure that the correct
% subject data are being used.  This is done in the Constants.m file and
% the goalDataFiles.m file.  Constants.m specifies the list of subjects for
% on which the scripts shouldbe run and goalDataFiles.m specifies what
% files will be used for each subject.

% A_PlotCoverage.m
%   simply generates a brain plot for each subject in their native brain
%   space showing the electrodes that were recorded during the experimental
%   sessions as well as specifically which electrode was used for control
A_PlotCoverage;

% B_RawInspect.m
%   This 
%   this script exctracts raw data for all trials for a subject, and allows
%   the runner to mark bad channels / epochs.
B_RawInspect;

% B_Behavioral.m
%   extracts behavioral data, including target type, trial performance,
%   integrated squared error of cursor trajectory throughout the trial, and
%   whether the subject was even headed in the right direction.
%
%   subsequently generates plots of these behavioral metrics as a function
%   of trial number for each subject.
%
%   lastly performs statistical analyses of these outcomes relative to one
%   of the three target factors that we are varying: size, distance,
%   direction.
Z_ChancePerformanceAnalysis; % this generates chance performance levels for
  % the behavioral metrics of interest
B_Behavioral;

% C_ExtractEpochAverages
%   this is a fairly slow script that calculates the epoch means for a
%   bunch of sub epochs within each run, specifically: rest, pre feedback
%   (which is further divided in to targeting and hold), and feedback.  All
%   of these phases are of fixed length except for feedback which is of
%   variable length.  This script calculates these mean power values for a
%   variety of frequencies as are listed in Constants.m
%
%   This script also saves out downsampled timeseries of HG and beta
%   features for future analysis and for example figures.
C_ExtractEpochAverages;

% E_AreasShowingModulation
%   simple ttest of epoch averages relative to rest on a subject by subject
%   basis.
E_AreasShowingModulation;

% F_AreasShowingDifferencesByCondition
%   simple ttest of epoch averages across target characteristics on a 
%   subject by subject basis.
F_AreasShowingDifferencesByCondition;

% H_ClassificationAnalyses
%   Comment TODO
H_ClassificationAnalyses;


