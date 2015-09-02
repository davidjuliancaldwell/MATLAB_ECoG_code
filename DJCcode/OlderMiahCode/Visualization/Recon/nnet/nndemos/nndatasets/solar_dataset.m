function targets = solar_dataset
%SOLAR_DATASET Sunspot activity dataset
%
% Single time-series prediction involves predicting the next value of
% a time-series given its past values.
%
% This dataset can be used to train a neural network to predict monthly
% mean numbers of sunspots.
%
% LOAD <a href="matlab:doc solar_dataset">solar_dataset</a>.MAT loads this variable:
%
%   solarTargets - a 1x2899 cell array of scalar values recording
%   2899 months of mean solar sunspots.
%
% T = <a href="matlab:doc solar_dataset">solar_dataset</a> loads the targets into a variable of your
% choosing.
%
% Periodicities in sunspot numbers are well established with periods
% of 11 years and 27 days.  The 11 year cycle is the period at which
% the Sun's magnetic field reverses and regenerates itself.  The 27
% day period is the Sun's rotation period.  Establishing the existence
% of other real periods in solar observational data has long been
% of interest because they provide insight into the mechanisms of
% solar variability.
%  
% Two periods which are currently being debated are those near 155 days
% (Lean and Brueckner 1989; Sturrock and Bai 1992) and one near 2.2 years
% (Shapiro and Ward 1962; Sakurai 1979).  There has even been one reported
% at 31 years (Bai 1988).  In addition to detecting periods, there is value
% in predicting sunspot numbers.  The Box-Jenkins (1976) method is most
% commonly used, but recently nonparametric kernel density estimators
% have been claimed to be superior (Cerrito 1992).
%  
% This file gives the monthly mean sunspot numbers for a 240 year period
% that starts from January of 1749 and runs to July of 1990.
%
% For an intro to prediction with the <a href="matlab:ntstool">NN Time Series Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a neural network that predicts the target series
% from past values. See <a href="matlab:doc narnet">narnet</a> for details.
%   
%   T = <a href="matlab:doc solar_dataset">solar_dataset</a>;
%   net = <a href="matlab:doc narnet">narnet</a>(1:2,10);
%   [Xs,Xi,Ai,Ts] = preparets(net,{},{},T);
%   net = <a href="matlab:doc train">train</a>(net,X,T,Xi,Ai);
%   <a href="matlab:doc view">view</a>(net)
%   Y = net(Xs,Xi,Ai)
%   plotresponse(T,Y)
%
% See also NTSTOOL, NARNET, PREPARETS, NNDATASETS.
%
% ---------
%
% http://xweb.nrl.navy.mil/timeseries/multi.diskette

% Copyright 2010 The MathWorks, Inc.

load solar_dataset
targets = solarTargets;
