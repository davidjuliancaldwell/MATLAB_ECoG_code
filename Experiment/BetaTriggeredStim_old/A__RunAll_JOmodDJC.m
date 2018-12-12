%% scripts to do analysis of beta-triggered stim data
% originally started by JDW, modified by JDO in 2015
% note: each "top level" script needs the SID updated for each subject run

%% Build Stim Tables
% this goes through the recordings for each subject and creates a matrix
% that logs relevant information about all of the stimuli provided
A_BuildStimTablesDJC;

%% Extract Neural Data
% this script pre-processes neural data and extracts peri-stimulus event
% timeseries data for each recorded channel
B_ExctractNeuralDataDJC;

%% Evaluate Stimulus Triggers
% this script looks at neural data from the triggering channel to quantify
% at what phase of the beta wave we were stimulating and how much
% variability there was
C_BuildEPTablesDJC;

%% Compare EPs
% this script performs comparisons of EPs from some/all channels...TBD
% D_CompareEPs

