function [inputs,targets] = simplefit_dataset
%SIMPLEFIT_DATASET Simple fitting dataset
%
% Function fitting is the process of training a neural network on a
% set of inputs in order to produce an associated set of target outputs.
% Once the neural network has fit the data, it forms a generalization of
% the input-output relationship and can be used to generate outputs for
% inputs it was not trained on.
%
% This dataset can be used to demonstrate how a neural network can be
% trained to estimate the relationship between two sets of data.
% 
% LOAD <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>.MAT loads these two variables:
%
%   simplefitInputs - a 1x67 matrix defining 67 input values.
%
%   simplefitTargets - a 1x67 matrix defining 67 associated target values.
%
% [X,T] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a> loads the inputs and targets into
% variables of your own choosing.
%
% To solve this problem with the <a href="matlab:nftool">Neural Network Fitting Tool</a> click
% "Load Example Data Set" in the "Select Data" panel and pick this dataset.
%
% Here is how to solve to this problem at the command line, with a fitting
% neural network with 10 hidden neurons. See <a href="matlab:doc fitnet">fitnet</a> for more details.
%
%   [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%   plot(x,t)
%   net = <a href="matlab:doc fitnet">fitnet</a>(10);
%   net = <a href="matlab:doc train">train</a>(net,x,t);
%   <a href="matlab:doc view">view</a>(net)
%   y = net(x);
%   plot(net,x,t);
%
% This data was created with <a href="matlab:doc simplefit_create">simplefit_create</a>.
%
% See also NFTOOL, FITNET, PLOTFIT, NNDATASETS.

% Copyright 2010 The MathWorks, Inc.

load simplefit_dataset
inputs = simplefitInputs;
targets = simplefitTargets;
