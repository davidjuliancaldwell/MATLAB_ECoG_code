function [inputs,targets] = cho_dataset
%CHO_DATASET Cholesterol dataset
%
% Function fitting is the process of training a neural network on a
% set of inputs in order to produce an associated set of target outputs.
% Once the neural network has fit the data, it forms a generalization of
% the input-output relationship and can be used to generate outputs for
% inputs it was not trained on.
%
% This dataset can be used to train a neural network to estimate
% cholesterol levels from a spectral analysis of blood.
%
% LOAD <a href="matlab:doc cho_dataset">cho_dataset</a>.MAT loads these two variables:
%
%   choInputs - a 21x264 matrix defining twenty-one spectral measurements
%   of 264 blood samples.
%
%   choTargets - a 3x264 matrix of levels of three kinds of cholesterol
%   for each blood sample.
%
%     1. LDL
%     2. VLDL
%     3. HDL
%
% [X,T] = <a href="matlab:doc cho_dataset">cho_dataset</a> loads the inputs and targets into
% variables of your own choosing.
%
% For an intro to fitting with the <a href="matlab:nftool">NN Fitting Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a fitting neural network with 10 hidden neurons
% with this data at the command line.  See <a href="matlab:doc fitnet">fitnet</a> for more details.
%
%   [x,t] = <a href="matlab:doc cho_dataset">cho_dataset</a>;
%   net = <a href="matlab:doc fitnet">fitnet</a>(10);
%   net = <a href="matlab:doc train">train</a>(net,x,t);
%   <a href="matlab:doc view">view</a>(net)
%   y = net(x);
%
% See also NFTOOL, NEWFIT, NNDATASETS.

% Copyright 2010 The MathWorks, Inc.

load cho_dataset
inputs = choInputs;
targets = choTargets;
