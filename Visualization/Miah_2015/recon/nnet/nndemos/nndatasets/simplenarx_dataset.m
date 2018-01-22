function [inputs,targets] = simplenarx_dataset
%SIMPLENARX_DATASET Simple time-series prediction dataset
%
% Input-output time series problems consist of predicting the next value
% of one time-series given another time-series. Past values of both series
% (for best accuracy), or only one of the series (for a simpler system)
% may be used to predict the target series.
%
% This dataset can be used to demonstrate how a neural network can be
% trained to make predictions.
%
% LOAD <a href="matlab:doc simplenarx_dataset">simplenarx_dataset</a>.MAT loads these two variables:
%
%   simplenarxInputs - a 1x100 cell array of scalar values representing
%   a 100 timestep time-series.
%
%   simplenarxTargets - a 1x100 cell array of scalar values representing
%   a 100 timestep time-series to be predicted.
%
% [X,T] = <a href="matlab:doc simplenarx_dataset">simplenarx_dataset</a> loads the inputs and targets into
% variables of your own choosing.
%
% For an intro to prediction with the <a href="matlab:ntstool">NN Time Series Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a neural network that predicts the target series
% from past values of inputs and targets. See <a href="matlab:doc narxnet">narxnet</a> for more details.
%
%   [X,T] = <a href="matlab:doc simplenarx_dataset">simplenarx_dataset</a>;
%   net = <a href="matlab:doc narxnet">narxnet</a>(1:2,1:2,10);
%   [Xs,Xi,Ai,Ts] = preparets(net,X,{},T);
%   net = <a href="matlab:doc train">train</a>(net,Xs,Ts,Xi,Ai);
%   <a href="matlab:doc view">view</a>(net)
%   Y = net(Xs,Xi,Ai)
%   plotresponse(Ts,Y)
%
% Here is how to design a neural network that predicts the target series
% from only using past values of inputs. See <a href="matlab:doc timedelaynet">timedelaynet</a> for details.
%   
%   net = <a href="matlab:doc timedelaynet">timedelaynet</a>(1:2,10);
%   [Xs,Xi,Ai,Ts] = preparets(net,X,T);
%   net = <a href="matlab:doc train">train</a>(net,Xs,Ts,Xi,Ai);
%
% Here is how to design a neural network that predicts the targets series
% only using past values of the target series. See <a href="matlab:doc narnet">narnet</a> for details.
%
%   net = <a href="matlab:doc narnet">narnet</a>(1:2,10);
%   [Xs,Xi,Ai,Ts] = preparets(net,{},{},T);
%   net = <a href="matlab:doc train">train</a>(net,X,T,Xi,Ai);
%
% See also NTSTOOL, NARXNET, TIMEDELAYNET, NARNET, PREPARETS, NNDATASETS.

% Copyright 2010 The MathWorks, Inc.

load simplenarx_dataset
inputs = simplenarxInputs;
targets = simplenarxTargets;
