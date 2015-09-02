function [inputs,targets] = building_dataset
%BUILDING_DATASET Building energy dataset.
%
% Function fitting is the process of training a neural network on a
% set of inputs in order to produce an associated set of target outputs.
% Once the neural network has fit the data, it forms a generalization of
% the input-output relationship and can be used to generate outputs for
% inputs it was not trained on.
%
% This dataset can be used to train a neural network to estimate the
% energy use of a building from time and weather conditions.
%
% LOAD <a href="matlab:doc building_dataset">building_dataset</a>.MAT loads these two variables:
%
%   buildingInputs - a 14x4208 matrix defining fourteen attributes for 4208
%   different houses.
%
%     1-10. Coded day of week, time of day
%     11. Temperature
%     12. Humidity
%     13. Solar strength
%     14. Wind
%
%   buildingTargets - a 3x4208 matrix of energy usage, to be estimated
%   from the inputs.
%
% [X,T] = <a href="matlab:doc building_dataset">building_dataset</a> loads the inputs and targets into
% variables of your own choosing.
%
% For an intro to fitting with the <a href="matlab:nftool">NN Fitting Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a fitting neural network with 10 hidden neurons
% with this data at the command line.  See <a href="matlab:doc fitnet">fitnet</a> for more details.
%
%   [x,t] = <a href="matlab:doc building_dataset">building_dataset</a>;
%   net = <a href="matlab:doc fitnet">fitnet</a>(10);
%   net = <a href="matlab:doc train">train</a>(net,x,t);
%   <a href="matlab:doc view">view</a>(net)
%   y = net(x);
%
% See also NFTOOL, FITNET, NNDATASETS.

% Copyright 2010 The MathWorks, Inc.

load building_dataset
inputs = buildingInputs;
targets = buildingTargets;
