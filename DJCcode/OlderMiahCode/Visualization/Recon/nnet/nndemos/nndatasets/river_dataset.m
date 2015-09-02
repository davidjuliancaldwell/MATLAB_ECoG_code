function targets = river_dataset
%RIVER_DATASET River flow dataset
%
% Single time-series prediction involves predicting the next value of
% a time-series given its past values.
%
% This dataset can be used to train a neural network to predict monthly
% river flows of the Sacramento River.
%
% LOAD <a href="matlab:doc river_dataset">river_dataset</a>.MAT loads this variable:
%
%   riverTargets - a 1x264 cell array of scalar values recording
%   264 months of river flow measurements taken at Keswick,
%   California from October 1939 to September 1960.
%
% T = <a href="matlab:doc river_dataset">river_dataset</a> loads the targets into a variable of your
% choosing.
%
% For an intro to prediction with the <a href="matlab:ntstool">NN Time Series Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a neural network that predicts the target series
% from past values. See <a href="matlab:doc narnet">narnet</a> for details.
%   
%   T = <a href="matlab:doc river_dataset">river_dataset</a>;
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
% http://www-personal.buseco.monash.edu.au/~hyndman/TSDL/
% The Time Series Data Library was created by Rob Hyndman.
% 
% Hyndman, R.J. (n.d.) Time Series Data Library, . Accessed on July 1,
% 2009.

% Copyright 2010 The MathWorks, Inc.

load river_dataset
targets = riverTargets;
