function [inputs,targets] = ph_dataset
%PH_DATASET Solution PH dataset
%
% Input-output time series problems consist of predicting the next value
% of one time-series given another time-series. Past values of both series
% (for best accuracy), or only one of the series (for a simpler system)
% may be used to predict the target series.
%
% This dataset can be used to train a neural network to predict the ph
% of a solution in a tank from acid and base solution flow.
%
% LOAD <a href="matlab:doc ph_dataset">ph_dataset</a>.MAT loads these two variables:
%
%   phInputs - a 1x2001 cell array of 2x1 vectors representing two
%   measurements over 2001 timesteps.
%
%     1. Acid solution flow in liters
%     2. Base solution flow in liters
%
%   phTargets - a 1x2001 cell array of scalar values representing
%   2001 timesteps of the ph of a solution in the tank.
%
% The simulation data is of a pH neutralization process in a constant tank
% volume of 1100 liters. The acid solution concentration was (HAC)
% 0.0032 Mol/l. The the base solution concentration was (NaOH) 0,05 Mol/l.
%
% [X,T] = <a href="matlab:doc ph_dataset">ph_dataset</a> loads the inputs and targets into
% variables of your own choosing.
%
% For an intro to prediction with the <a href="matlab:ntstool">NN Time Series Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a neural network that predicts the target series
% from past values of inputs and targets. See <a href="matlab:doc narxnet">narxnet</a> for more details.
%
%   [X,T] = <a href="matlab:doc ph_dataset">ph_dataset</a>;
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
% ----------
%
% T.J. Mc Avoy, E.Hsu and S.Lowenthal, Dynamics of pH in controlled 
% stirred tank reactor, Ind.Eng.Chem.Process Des.Develop.11(1972)
% 71-78
% 
% Source: Jairo Espinosa, K.U.Leuven ESAT-SISTA

% Copyright 2010 The MathWorks, Inc.

load ph_dataset
inputs = phInputs;
targets = phTargets;
