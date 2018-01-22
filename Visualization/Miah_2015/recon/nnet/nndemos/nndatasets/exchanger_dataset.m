function [inputs,targets] = exchanger_dataset
%EXCHANGER_DATASET Heat exchanger dataset
%
% Input-output time series problems consist of predicting the next value
% of one time-series given another time-series. Past values of both series
% (for best accuracy), or only one of the series (for a simpler system)
% may be used to predict the target series.
%
% This dataset can be used to train a neural network to predict the outlet
% liquid temperature of a liquid-saturated steam heat exchanger, from past
% outlet liquid temperatures and/or the liquid flow rate.
%
% LOAD <a href="matlab:doc exchanger_dataset">exchanger_dataset</a>.MAT loads these two variables:
%
%   exchangerInputs - a 1x4000 cell array of scalar values representing
%   4000 time steps of liquid flow rates.
%
%   exchangerTargets - a 1x4000 cell array of scalar values representing
%   4000 timesteps of outlet liquid temperatures.
%
% The sample time for this data was one second.
%
% Water is heated by pressurized saturated steam through a copper tube.
% In this experiment the steam temperature and the inlet liquid temperature,
% which would also have an effect, were kept constant.
%
% The heat exchanger process is a significant benchmark for nonlinear
% control design purposes, since it is characterized by a non minimum
% phase behaviour.  In the references cited below the control problem of
% regulating the output temperature of the liquid-satured steam heat
% exchanger by acting on the liquid flow rate is addressed, and both
% direct and inverse identifications of the data are performed.
%
% [X,T] = <a href="matlab:doc exchanger_dataset">exchanger_dataset</a> loads the inputs and targets into
% variables of your own choosing.
%
% For an intro to prediction with the <a href="matlab:ntstool">NN Time Series Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a neural network that predicts the target series
% from past values of inputs and targets. See <a href="matlab:doc narxnet">narxnet</a> for more details.
%
%   [X,T] = <a href="matlab:doc exchanger_dataset">exchanger_dataset</a>;
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
%   net = <a href="matlab:doc train">train</a>(net,X,T,Xi,Ai);
%
% Here is how to design a neural network that predicts the targets series
% only using past values of the target series. See <a href="matlab:doc narnet">narnet</a> for details.
%
%   net = <a href="matlab:doc narnet">narnet</a>(1:2,10);
%   [Xs,Xi,Ai,Ts] = preparets(net,{},{},T);
%   net = <a href="matlab:doc train">train</a>(net,Xs,Ts,Xi,Ai);
%
% See also NTSTOOL, NARXNET, TIMEDELAYNET, NARNET, PREPARETS, NNDATASETS.
%
% ---------
%
% This data is available from DaISy:
% 
% De Moor B.L.R. (ed.), DaISy: Database for the Identification of Systems,
% Department of Electrical Engineering, ESAT/SISTA, K.U.Leuven, Belgium,
% URL: http://homes.esat.kuleuven.be/~smc/daisy/, date of visit.
% 
% Contributed by: Sergio Bittanti
% Politecnico di Milano
% Dipartimento di Elettronica e Informazione,
% Politecnico di Milano, 
% Piazza Leonardo da Vinci 32, 20133 MILANO (Italy)
% bittanti@elet.polimi.it
%  
% S. Bittanti and L. Piroddi, "Nonlinear identification and control of a
% heat exchanger: a neural network approach", Journal of the Franklin
% Institute, 1996.  L. Piroddi, Neural Networks for Nonlinear Predictive
% Control. Ph.D. Thesis, Politecnico di Milano (in Italian), 1995.

% Copyright 2010-2011 The MathWorks, Inc.

load exchanger_dataset
inputs = exchangerInputs;
targets = exchangerTargets;
