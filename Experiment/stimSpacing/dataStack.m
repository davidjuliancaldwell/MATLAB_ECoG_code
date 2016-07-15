%% dataStack function for SVD analysis

function [dataStackedGood] = dataStack(dataEpoched,t,post_begin,post_end,channelsOfInt,stim_1,stim_2,bads,fs_data,filter_it)
% DATASTACK stacks data for SVD analysis 
% This function takes an input structure in time x channels x trials format
% and stacks all time points, following a beginning time point and before
% an ending one, for a list of good channels, while excluding bad channels
% (always excluding stimulation channels). The next call could for svd or
% something similar 

numChans = size(dataEpoched,2);

% use defaults if arguments not supplied in function call
if(~exist('bads','var'))
    bads = [];
end

if(~exist('stim_1','var'))
    stim_1  = [];
end

if(~exist('stim-2','var'))
    stim_2 = [];
end

if(~exist('channelsOfInt','var'))
    channelsOfInt = [1:numChans];
end

if(~exist('filter_it','var'))
    filter_it = 'y';
end


% this selects all of the data after the beginning window and before the
% ending window

dataNoStim = dataEpoched((t>post_begin & t<post_end),:,:);

% reshift the data so we can do a vector operation to stack all of it like
% we did for that one example
data_permuted  = permute(dataNoStim,[1,3,2]);

% stack the data

data_stacked = reshape(data_permuted,[size(data_permuted,1)*size(data_permuted,2),size(data_permuted,3)]);

% make a vector of all of the channels we have
goods = zeros(numChans,1);

% pick the good channels
goods(channelsOfInt) = 1;

% pick the ones to ignore
badTotal = [stim_1,stim_2,bads];
goods(badTotal) = 0;

% 7-13-2016 - input channels of interest

% make a logical matrix
goods = logical(goods);

% select the good channels
dataStackedGood = data_stacked(:,goods);

% decide if we want to filter it
idx = 60;
if strcmp(filter_it,'y')
    dataStackedGood = notch(dataStackedGood,[60 120 180 240],fs_data);
    figure
    % plot the filtered data for a sanity check
    plot(dataStackedGood(:,idx));
end


end