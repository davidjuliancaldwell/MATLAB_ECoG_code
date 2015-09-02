function [inputs,targets] = chemical_dataset
%CHEMICAL_DATASET Chemical sensor dataset
%
% Function fitting is the process of training a neural network on a
% set of inputs in order to produce an associated set of target outputs.
% Once the neural network has fit the data, it forms a generalization of
% the input-output relationship and can be used to generate outputs for
% inputs it was not trained on.
%
% This dataset can be used to train a neural network to estimate one
% sensor signal from eight other sensor signals.
%
% LOAD <a href="matlab:doc chemical_dataset">chemical_dataset</a>.MAT loads these two variables:
%
%   chemicalInputs - a 8x498 matrix defining measurements taken from
%   eight sensors during a chemical process.
%
%   chemicalTargets - a 1x498 matrix of a ninth sensor's measurements, to
%   be estimated from the first eight.
%
%   A good estimator for the ninth sensor will allow it to be removed
%   and estimations used in its place.
%
% [X,T] = <a href="matlab:doc chemical_dataset">chemical_dataset</a> loads the inputs and targets into
% variables of your own choosing.
%
% For an intro to fitting with the <a href="matlab:nftool">NN Fitting Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a fitting neural network with 10 hidden neurons
% with this data at the command line.  See <a href="matlab:doc fitnet">fitnet</a> for more details.
%
%   [x,t] = <a href="matlab:doc chemical_dataset">chemical_dataset</a>;
%   net = <a href="matlab:doc fitnet">fitnet</a>(10);
%   net = <a href="matlab:doc train">train</a>(net,x,t);
%   <a href="matlab:doc view">view</a>(net)
%   y = net(x);
%
% See also NFTOOL, FITNET, NNDATASETS.

% Copyright 2010 The MathWorks, Inc.

load chemical_dataset
inputs = chemicalInputs;
targets = chemicalTargets;
