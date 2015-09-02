function [inputs,targets] = iris_dataset
%IRIS_DATASET Iris flower dataset
%
% Pattern recognition is the process of training a neural network to assign
% the correct target classes to a set of input patterns.  Once trained the
% network can be used to classify patterns it has not seen before.
%
% This dataset can be used to create a neural network that classifies iris
% flowers into three species.
%
% LOAD <a href="matlab:doc iris_dataset">iris_dataset</a>.MAT loads these two variables:
%
%   irisInputs - a 4x150 matrix of four attributes of 1000 flowers.
%
%     1. Sepal length in cm
%     2. Sepal width in cm
%     3. Petal length in cm
%     4. Petal width in cm
%
%   irisTargets - a 3x150 matrix of 1000 associated class vectors
%   defining which of four classes each input is assigned to.  Classes
%   are represented by a 1 in one of four rows, with zeros in the others.
%
% [X,T] = <a href="matlab:doc iris_dataset">iris_dataset</a> loads the inputs and targets into
% variables of your own choosing.
%
% For an intro to pattern recognition with the <a href="matlab:nprtool">NN Pattern Recognition Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a pattern recognition neural network with this
% data at the command line.  See <a href="matlab:doc patternnet">patternnet</a> for more details.
%
%   [x,t] = <a href="matlab:doc iris_dataset">iris_dataset</a>;
%   net = <a href="matlab:doc patternnet">patternnet</a>(10);
%   net = <a href="matlab:doc train">train</a>(net,x,t);
%   <a href="matlab:doc view">view</a>(net)
%   y = net(x);
%   plotconfusion(t,y)
%
% Clustering is the process of training a neural network on patterns
% so that the network comes up with its own classifications according
% to pattern similarity and relative topology.  This is useful for gaining
% insight into data, or simplifying it before further processing.
%
% For an intro to clustering with the <a href="matlab:nctool">NN Clustering Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design an 8x8 clustering neural network with this data at
% the command line.  See <a href="matlab:doc selforgmap">selforgmap</a> for more details.
%
%   x = <a href="matlab:doc simplecluster_dataset">simplecluster_dataset</a>;
%   plot(x(1,:),x(2,:),'+')
%   net = <a href="matlab:doc selforgmap">selforgmap</a>([8 8]);
%   net = <a href="matlab:doc train">train</a>(net,x);
%   <a href="matlab:doc view">view</a>(net)
%   y = net(x);
%   classes = vec2ind(y);
%   
% See also NPRTOOL, PATTERNNET, NCTOOL, SELFORGMAP, NNDATASETS.
%
% ----------
%
% This data is available from the UCI Machine Learning Repository.
%
%   http://mlearn.ics.uci.edu/MLRepository.html
%
% Murphy,P.M., Aha, D.W. (1994). UCI Repository of machine learning
% databases [http://www.ics.uci.edu/~mlearn/MLRepository.html].
% Irvine, CA: University of California,  Department of Information
% and Computer Science.
%
% From R.A. Fisher.

% Copyright 2010 The MathWorks, Inc.

load iris_dataset
inputs = irisInputs;
targets = irisTargets;
