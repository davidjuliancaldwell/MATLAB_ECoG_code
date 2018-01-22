function [inputs,targets] = abalone_dataset
%ABALONE_DATASET Abalone shell rings dataset.
%
% Function fitting is the process of training a neural network on a
% set of inputs in order to produce an associated set of target outputs.
% Once the neural network has fit the data, it forms a generalization of
% the input-output relationship and can be used to generate outputs for
% inputs it was not trained on.
%
% This dataset can be used to train a neural network to estimate the
% number of abalone shell rings from attributes of the shell.
%
% LOAD <a href="matlab:doc abalone_dataset">abalone_dataset</a>.MAT loads these two variables:
%
%   abaloneInputs - an 8x4177 matrix defining eight attributes for 4177
%   different shells.
%
%     1. Sex: M, F, and I (infant)
%     2. Length
%     3. Diameter
%     4. Height
%     5. Whole weight
%     6. Shucked weight
%     7. Viscera weight
%     8. Shell weight
%
%   abaloneTargets - a 1x4177 matrix of ring counts for each shell.
%
% The number of rings of an abolone shell is a useful value to estimate
% as it can be used to compute the age by adding 1.5.
%
% [X,T] = <a href="matlab:doc abalone_dataset">abalone_dataset</a> loads the inputs and targets into
% variables of your own choosing.
%
% For an intro to fitting with the <a href="matlab:nftool">NN Fitting Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a fitting neural network with 10 hidden neurons
% with this data at the command line.  See <a href="matlab:doc fitnet">fitnet</a> for more details.
%
%   [x,t] = <a href="matlab:doc abalone_dataset">abalone_dataset</a>;
%   net = <a href="matlab:doc fitnet">fitnet</a>(10);
%   net = <a href="matlab:doc train">train</a>(net,x,t);
%   <a href="matlab:doc view">view</a>(net)
%   y = net(x);
%
% See also NFTOOL, FITNET, NNDATASETS.
%
% ----------
%
% This data is available from the UCI Machine Learning Repository.
%
%   http://mlearn.ics.uci.edu/MLRepository.html
%
% Murphy,P.M., Aha, D.W. (1994). UCI Repository of machine learning
% databases [http://www.ics.uci.edu/~mlearn/MLRepository.html].
% Irvine, CA: University of California,  Department of Information
% and Computer Science.
%
% Donated to the repository by Sam Waugh.

% Copyright 2010 The MathWorks, Inc.

load abalone_dataset
inputs = abaloneInputs;
targets = abaloneTargets;
