function [inputs,targets] = pollution_dataset
%POLLUTION_DATASET Pollution mortality dataset
%
% Input-output time series problems consist of predicting the next value
% of one time-series given another time-series. Past values of both series
% (for best accuracy), or only one of the series (for a simpler system)
% may be used to predict the target series.
%
% This dataset can be used to train a neural network to predict mortality
% due to pollution.
%
% LOAD <a href="matlab:doc pollution_dataset">pollution_dataset</a>.MAT loads these two variables:
%
%   pollutionInputs - a 1x219 cell array of 8x1 vectors representing
%   eight measurements over 219 timesteps.
%
%     1. Temperature
%     2. Relative humidity
%     3. Carbon monoxide
%     4. Sulfer dioxide
%     5. Nitrogen dioxide
%     6. Hydrocarbons
%     7. Ozone
%     8. Particulates
%
%   pollutionTargets - a 2x219 cell array of 3x1 vectors representing
%   a 219 timesteps of three kinds of mortality to be predicted.
%
%     1. Total mortality
%     2. Respiratory mortality
%     3. Cardiovascular mortality
%
% [X,T] = <a href="matlab:doc pollution_dataset">pollution_dataset</a> loads the inputs and targets into
% variables of your own choosing.
%
% For an intro to prediction with the <a href="matlab:ntstool">NN Time Series Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a neural network that predicts the target series
% from past values of inputs and targets. See <a href="matlab:doc narxnet">narxnet</a> for more details.
%
%   [X,T] = <a href="matlab:doc pollution_dataset">pollution_dataset</a>;
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
%
% ---------
%
% This data was obtained from StatLib.
% http://lib.stat.cmu.edu/datasets/
% 
% Shumway, R.H., A.S. Azari and Y. Pawitan (1988). Modeling mortality
% fluctuations in Los Angeles as functions of pollution and weather
% effects.  Environmental Research, 45, 224-241.

% Copyright 2010 The MathWorks, Inc.

load pollution_dataset
inputs = pollutionInputs;
targets = pollutionTargets;
