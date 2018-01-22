function targets = oil_dataset
%OIL_DATASET Monthly oil price dataset
%
% Single time-series prediction involves predicting the next value of
% a time-series given its past values.
%
% This dataset can be used to train a neural network to predict monthly
% gas and oil prices.
%
% LOAD <a href="matlab:doc oil_dataset">oil_dataset</a>.MAT loads this variable:
%
%   oilTargets - a 1x498 cell array of 2x1 vectors representing
%   498 months of fuel prices from July 1973 to December 1987.
%
%     1. Gas prices
%     2. Oil prices
%
% T = <a href="matlab:doc oil_dataset">oil_dataset</a> loads the targets into a variable of your
% choosing.
%
% For an intro to prediction with the <a href="matlab:ntstool">NN Time Series Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a neural network that predicts the target series
% from past values. See <a href="matlab:doc narnet">narnet</a> for details.
%   
%   T = <a href="matlab:doc oil_dataset">oil_dataset</a>;
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
% 
% Liu, L.M. (1991). Dynamic relationship analysis of U.S. gasoline
% and crude oil prices. J. of Forecasting, 10, 521-547.

% Copyright 2010 The MathWorks, Inc.

load oil_dataset
targets = oilTargets;
