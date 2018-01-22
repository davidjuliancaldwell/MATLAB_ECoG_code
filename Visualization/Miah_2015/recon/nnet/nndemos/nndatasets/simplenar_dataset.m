function targets = simplenar_dataset
%SIMPLENAR_DATASET Simple time-series prediction dataset
%
% Single time-series prediction involves predicting the next value of
% a time-series given its past values.
%
% This dataset can be used to demonstrate how a neural network is
% trained to make predictions.
%
% LOAD <a href="matlab:doc simplenar_dataset">simplenar_dataset</a>.MAT loads this variable:
%
%   simpleseriesTargets - a 1x100 cell array of scalar values representing
%   a 100 timestep time-series.
%
% T = <a href="matlab:doc simplenar_dataset">simplenar_dataset</a> loads the targets into a variable of your
% choosing.
%
% For an intro to prediction with the <a href="matlab:ntstool">NN Time Series Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a neural network that predicts the target series
% from past values. See <a href="matlab:doc narnet">narnet</a> for details.
%   
%   T = <a href="matlab:doc simplenar_dataset">simplenar_dataset</a>;
%   net = <a href="matlab:doc narnet">narnet</a>(1:2,10);
%   [Xs,Xi,Ai,Ts] = preparets(net,{},{},T);
%   net = <a href="matlab:doc train">train</a>(net,X,T,Xi,Ai);
%   <a href="matlab:doc view">view</a>(net)
%   Y = net(Xs,Xi,Ai)
%   plotresponse(T,Y)
%
% See also NTSTOOL, NARNET, PREPARETS, NNDATASETS.

% Copyright 2010 The MathWorks, Inc.

load simplenar_dataset
targets = simplenarTargets;
