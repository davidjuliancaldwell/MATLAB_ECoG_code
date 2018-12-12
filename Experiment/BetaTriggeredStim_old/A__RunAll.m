%% scripts to do analysis of beta-triggered stim data

%% Build Stim Tables
% this goes through the recordings for each subject and creates a matrix
% that logs relevant information about all of the stimuli provided
A_BuildStimTables;

%% Extract Neural Data
% this script pre-processes neural data and extracts peri-stimulus event
% timeseries data for each recorded channel
B_ExctractNeuralData;

%% Evaluate Stimulus Triggers
% this script looks at neural data from the triggering channel to quantify
% at what phase of the beta wave we were stimulating and how much
% variability there was
C_EvaluateStimulusTriggers;

%% Compare EPs
% this script performs comparisons of EPs from some/all channels
D_CompareEPs

