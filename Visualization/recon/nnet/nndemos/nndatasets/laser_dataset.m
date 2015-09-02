function targets = laser_dataset
%LASER_DATASET Chaotic far-infrared laser dataset
%
% Single time-series prediction involves predicting the next value of
% a time-series given its past values.
%
% This dataset can be used to train a neural network to model the
% chaotic behavior of a far-infrared laser.
%
% LOAD <a href="matlab:doc laser_dataset">laser_dataset</a>.MAT loads this variable:
%
%   laserTargets - a 1x10093 cell array of scalar values representing
%   10093 measurements of a far-infrared laser intensity over a period of
%   chaotic activity.
%
% T = <a href="matlab:doc laser_dataset">laser_dataset</a> loads the targets into a variable of your
% choosing.
%
% Here is the description from Dr. Huebner:
%
% The measurements were made on an 81.5-micron 14NH3 cw (FIR) laser,
% pumped optically by the P(13) line of an N2O laser via the vibrational
% aQ(8,7) NH3 transition. The basic laser setup can be found in Ref. 1.
% The intensity data was recorded by a LeCroy oscilloscope. No further
% processing happened. The experimental signal to noise ratio was about
% 300 which means slightly under the half bit uncertainty of the analog
% to digital conversion.
%
% The data is a cross-cut through periodic to chaotic intensity pulsations
% of the laser. Chaotic pulsations more or less follow the theoretical
% Lorenz model (see References) of a two level system.
%
% For an intro to prediction with the <a href="matlab:ntstool">NN Time Series Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a neural network that predicts the target series
% from past values. See <a href="matlab:doc narnet">narnet</a> for details.
%   
%   T = <a href="matlab:doc laser_dataset">laser_dataset</a>;
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
% This was one of the data sets used in the Santa Fe Competition, directed
% by  Neil Gershenfeld (now at MIT's Media Lab) and Andreas Weigend
% (http://www.weigend.com/).
% 
% http://www-psych.stanford.edu/~andreas/Time-Series/SantaFe.html
% 
% The data was contributed by Udo Huebner, Phys.-Techn. Bundesanstalt,
% Braunschweig, Germany, and were collected primarily by N. B. Abraham
% and C. O. Weiss. These data were recorded from a Far-Infrared-Laser
% in a chaotic state; 
%
% 1. U. Huebner, N. B. Abraham, and C. O. Weiss: "Dimensions and entropies
% of chaotic intensity pulsations in a single-mode far-infrared NH3 laser."
% Phys. Rev. A 40, p. 6354 (1989)
% 
% 2. U. Huebner, W. Klische, N. B. Abraham, and C. O. Weiss: "On problems
% encountered with dimension calculations." Measures of Complexity and
% Chaos; Ed. by N. B. Abraham et. al., Plenum Press, New York 1989, p. 133
% 
% 3. U. Huebner, W. Klische, N. B. Abraham, and C. O. Weiss: "Comparison of
% Lorenz-like laser behavior with the Lorenz model.'' Coherence and Quantum
% Optics VI; Ed. by J. Eberly et. al., Plenum Press, New York 1989, p. 517 

% Copyright 2010 The MathWorks, Inc.

load laser_dataset
targets = laserTargets;
