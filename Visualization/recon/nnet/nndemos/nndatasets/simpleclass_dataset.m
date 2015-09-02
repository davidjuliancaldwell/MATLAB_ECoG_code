function [inputs,targets] = simpleclass_dataset
%SIMPLECLASS_DATASET Simple classification dataset
%
% Pattern recognition is the process of training a neural network to assign
% the correct target classes to a set of input patterns.  Once trained the
% network can be used to classify patterns it has not seen before.
%
% This dataset can be used to demonstrate how a neural network can be
% trained to classify data using a set of examples.
%
% LOAD <a href="matlab:doc simpleclass_dataset">simpleclass_dataset</a>.MAT loads these two variables:
%
%   simpleclassInputs - a 2x1000 matrix of 1000 two-element vectors.
%
%   simpleclassTargets - a 4x1000 matrix where each column indicates a
%   category with a one in either element 1, 2, 3 or 4.
%
% [X,T] = <a href="matlab:doc simpleclass_dataset">simpleclass_dataset</a> loads the inputs and targets into
% variables of your own choosing.
%
% For an intro to pattern recognition with the <a href="matlab:nprtool">NN Pattern Recognition Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a pattern recognition neural network with this
% data at the command line.  See <a href="matlab:doc patternnet">patternnet</a> for more details.
%
%   [x,t] = <a href="matlab:doc simpleclass_dataset">simpleclass_dataset</a>;
%   plot(x(1,:),x(2,:),'+')
%   net = <a href="matlab:doc patternnet">patternnet</a>(10);
%   net = <a href="matlab:doc train">train</a>(net,x,t);
%   <a href="matlab:doc view">view</a>(net)
%   y = net(x)
%   plotconfusion(t,y)
%   
% This data was created with <a href="matlab:doc simpleclass_create">simpleclass_create</a>.
%
% See also NPRTOOL, PATTERNNET, NNDATASETS.

% Copyright 2010 The MathWorks, Inc.

load simpleclass_dataset
inputs = simpleclassInputs;
targets = simpleclassTargets;
