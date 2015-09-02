function [inputs,targets] = simplecluster_dataset
%SIMPLECLUSTER_DATASET Simple clustering dataset
%
% Clustering is the process of training a neural network on patterns
% so that the network comes up with its own classifications according
% to patterns similarity and relative topology.  This useful for gaining
% insight into data, or simplifying it before further processing.
%
% This dataset can be used to demonstrate how a neural network can be
% trained develop its own classification system for a set of examples.
%
% LOAD <a href="matlab:doc simplecluster_dataset">simplecluster_dataset</a>.MAT loads these two variables:
%
%   simpleclusterInputs - a 2x1000 matrix of 1000 two-element vectors.
%
% [X,T] = <a href="matlab:doc simplecluster_dataset">simplecluster_dataset</a> loads the inputs and targets into
% variables of your own choosing.
%
% For an intro to clustering with the <a href="matlab:nftool">NN Clustering Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design an 8x8 clustering neural network with this data at
% the command line.  See <a href="matlab:doc selforgmap">selforgmap</a> for more details.
%
%   [x,t] = <a href="matlab:doc simplecluster_dataset">simplecluster_dataset</a>;
%   plot(x(1,:),x(2,:),'+')
%   net = <a href="matlab:doc selforgmap">selforgmap</a>([8 8]);
%   net = <a href="matlab:doc train">train</a>(net,x,t);
%   <a href="matlab:doc view">view</a>(net)
%   y = net(x);
%   classes = vec2ind(y);
%   
% This data was created with <a href="matlab:doc simplecluster_create">simplecluster_create</a>.
%
% See also NPRTOOL, PATTERNNET, NNDATASETS.

% Copyright 2010 The MathWorks, Inc.

load simpleclass_dataset
inputs = simpleclassInputs;
targets = simpleclassTargets;
