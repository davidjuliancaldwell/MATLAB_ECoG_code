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
%   the runner to mark bad channels / epochs. This script has to be run
%   manually for each subject, since there's a step to save out the markers
%   from felix's channel_inspector code.
B_RawInspect;

% C_ExtractData;
%   extracts behavioral and ECoG data for futher processing
C_ExtractData;

% D_Behavioral.m
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
D_Behavioral;

% E_CLClassResults
%   performs fairly basic statistical analyses of the closed-loop
%   classification experiments, providing results output as figures.
E_CLClassResults;

% F_PostHocClass
%   uses a similar (if not equivalent, save for being run in matlab)
%   pathway as the closed loop system, but goes back and performs
%   multi-fold train-test-val classification of intent using data from all
%   subjects.
F_PostHocClass;

% G_EvolutionOfRepresentation
%   this script looks at goal representation strength as a function of time
%   in HG, approximately demonstrating what we already saw from the RJB
%   data, that the real strong representation in macro ECoG is during task
%   execution, as opposed to beforehand.
G_EvolutionOfRepresentation;

% Multiple regression analyses
%   this series of scripts performs multiple regression analyses (a la
%   fMRI) on each ECoG channel separately to give an idea of the existence,
%   strength, and lag for relationships between task state and neural
%   activity.
H_RegressionModel_calclags; % calculates the lags between state and ecog
H_RegressionModel_mregress; % performs multiple regressions
H_RegressionModel_Show; % aggregates and plots the results
