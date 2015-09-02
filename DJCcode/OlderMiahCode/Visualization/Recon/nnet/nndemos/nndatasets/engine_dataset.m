function [inputs,targets] = engine_dataset
%ENGINE_DATASET Engine behavior dataset.
%
% Function fitting is the process of training a neural network on a
% set of inputs in order to produce an associated set of target outputs.
% Once the neural network has fit the data, it forms a generalization of
% the input-output relationship and can be used to generate outputs for
% inputs it was not trained on.
%
% This dataset can be used to train a neural network to estimate an
% engines torque and emissions from its fuel use and speed.
%
% LOAD <a href="matlab:doc engine_dataset">engine_dataset</a>.MAT loads these two variables:
%
%   engineInputs - a 2x1199 matrix defining two attributes of a
%   given engines activity under different conditions:
%
%     1. Fuel rate
%     2. Speed
%
%   engineTargets - a 2x1199 matrix of two attributes to be estimated
%   given the inputs:
%
%     1. Torque
%     2. Nitrous oxide emissions
%
% [X,T] = <a href="matlab:doc engine_dataset">engine_dataset</a> loads the inputs and targets into
% variables of your own choosing.
%
% For an intro to fitting with the <a href="matlab:nftool">NN Fitting Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a fitting neural network with 10 hidden neurons
% with this data at the command line.  See <a href="matlab:doc fitnet">fitnet</a> for more details.
%
%   [x,t] = <a href="matlab:doc engine_dataset">engine_dataset</a>;
%   net = <a href="matlab:doc fitnet">fitnet</a>(10);
%   net = <a href="matlab:doc train">train</a>(net,x,t);
%   <a href="matlab:doc view">view</a>(net)
%   y = net(x);
%
% See also NFTOOL, FITNET, NNDATASETS.
%
% ----------
%
% Donated by Prof. Martin T. Hagan, Oklahoma State University
% 
%   http://hagan.okstate.edu/

% Copyright 2010 The MathWorks, Inc.

load engine_dataset
inputs = engineInputs;
targets = engineTargets;
