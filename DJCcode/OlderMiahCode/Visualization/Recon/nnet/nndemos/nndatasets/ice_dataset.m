function targets = ice_dataset
%ICE_DATASET Gobal ice volume dataset
%
% Single time-series prediction involves predicting the next value of
% a time-series given its past values.
%
% This dataset can be used to train a neural network to predict global
% ice volume.
%
% LOAD <a href="matlab:doc ice_dataset">ice_dataset</a>.MAT loads this variable:
%
%   iceTargets - a 1x219 cell array of scalar values representing
%   219 measurements of global ice volume over the last 440,000 years.
%
% T = <a href="matlab:doc ice_dataset">ice_dataset</a> loads the targets into a variable of your
% choosing.
%
% For an intro to prediction with the <a href="matlab:ntstool">NN Time Series Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a neural network that predicts the target series
% from past values. See <a href="matlab:doc narnet">narnet</a> for details.
%   
%   T = <a href="matlab:doc ice_dataset">ice_dataset</a>;
%   net = <a href="matlab:doc narnet">narnet</a>(1:2,10);
%   [Xs,Xi,Ai,Ts] = preparets(net,{},{},T);
%   net = <a href="matlab:doc train">train</a>(net,X,T,Xi,Ai);
%   <a href="matlab:doc view">view</a>(net)
%   Y = net(Xs,Xi,Ai)
%   plotresponse(T,Y)
%
% See also NTSTOOL, NARNET, PREPARETS, NNDATASETS.
%
% ----------
%
% This data was obtained from StatLib.
% 
% http://lib.stat.cmu.edu/datasets/
% Global Ice Volume (440K-0 yrs BP, 220 Values) (1) Oxygen-18
% Newton, H.J. and G.R. North (1991). Forecasting global ice volume.
% J. Time Series Analysis, 12, 255-265.

% Copyright 2010 The MathWorks, Inc.

load ice_dataset
targets = iceTargets;
