function [inputs,targets] = bodyfat_dataset
%BODYFAT_DATASET Body fat percentage dataset.
%
% Function fitting is the process of training a neural network on a
% set of inputs in order to produce an associated set of target outputs.
% Once the neural network has fit the data, it forms a generalization of
% the input-output relationship and can be used to generate outputs for
% inputs it was not trained on.
%
% This dataset can be used to train a neural network to estimate the
% bodyfat of someone from various measurements.
%
% LOAD <a href="matlab:doc bodyfat_dataset">bodyfat_dataset</a>.MAT loads these two variables:
%
%   bodyfatInputs - a 13x252 matrix defining thirteen attributes for 252
%   people.
%
%     1. Age (years)
%     2. Weight (lbs)
%     3. Height (inches)
%     4. Neck circumference (cm)
%     5. Chest circumference (cm)
%     6. Abdomen 2 circumference (cm)
%     7. Hip circumference (cm)
%     8. Thigh circumference (cm)
%     9. Knee circumference (cm)
%    10. Ankle circumference (cm)
%    11. Biceps (extended) circumference (cm)
%    12. Forearm circumference (cm)
%    13. Wrist circumference (cm)
%
%   bodyfatTargets - a 1x252 matrix of associated body fat percentages,
%   to be estimated from the inputs.
%
% [X,T] = <a href="matlab:doc bodyfat_dataset">bodyfat_dataset</a> loads the inputs and targets into
% variables of your own choosing.
%
% For an intro to fitting with the <a href="matlab:nftool">NN Fitting Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a fitting neural network with 10 hidden neurons
% with this data at the command line.  See <a href="matlab:doc fitnet">fitnet</a> for more details.
%
%   [x,t] = <a href="matlab:doc bodyfat_dataset">bodyfat_dataset</a>;
%   net = <a href="matlab:doc fitnet">fitnet</a>(10);
%   net = <a href="matlab:doc train">train</a>(net,x,t);
%   <a href="matlab:doc view">view</a>(net)
%   y = net(x);
%
% See also NFTOOL, FITNET, NNDATASETS.

% Copyright 2010 The MathWorks, Inc.

load bodyfat_dataset
inputs = bodyfatInputs;
targets = bodyfatTargets;
