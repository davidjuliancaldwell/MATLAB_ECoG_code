function [inputs,targets] = ovarian_dataset
%OVARIAN_DATASET Ovarian cancer dataset
%
% Pattern recognition is the process of training a neural network to assign
% the correct target classes to a set of input patterns.  Once trained the
% network can be used to classify patterns it has not seen before.
%
% This dataset can be used to design a neural network that classifies
% patients into those who have ovarian cancer and those who do not.
%
% LOAD <a href="matlab:doc ovarian_dataset">ovarian_dataset</a>.MAT loads these two variables:
%
%   ovarianInputs - a 100x216 matrix defining 100 ion intensity levels
%   measured for 100 different specific mass-charge values, for 216
%   different patients.
%
%   ovarianTargets - a 1x216 matrix where each element indicates an
%   ovarian cancer patient with a 1, or a normal patient with a 0.
%   There are 121 cancer patients and 95 normal patients.
%
% [X,T] = <a href="matlab:doc ovarian_dataset">ovarian_dataset</a> loads the inputs and targets into
% variables of your own choosing.
%
% For an intro to pattern recognition with the <a href="matlab:nprtool">NN Pattern Recognition Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a pattern recognition neural network with this
% data at the command line.  See <a href="matlab:doc patternnet">patternnet</a> for more details.
%
%   [x,t] = <a href="matlab:doc ovarian_dataset">ovarian_dataset</a>;
%   net = <a href="matlab:doc patternnet">patternnet</a>(10);
%   net = <a href="matlab:doc train">train</a>(net,x,t);
%   <a href="matlab:doc view">view</a>(net)
%   y = net(x);
%   plotconfusion(t,y)
%   
% Clustering is the process of training a neural network on patterns
% so that the network comes up with its own classifications according
% to pattern similarity and relative topology.  This is useful for gaining
% insight into data, or simplifying it before further processing.
%
% For an intro to clustering with the <a href="matlab:nctool">NN Clustering Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design an 8x8 clustering neural network with this data at
% the command line.  See <a href="matlab:doc selforgmap">selforgmap</a> for more details.
%
%   x = <a href="matlab:doc ovarian_dataset">ovarian_dataset</a>;
%   plot(x(1,:),x(2,:),'+')
%   net = <a href="matlab:doc selforgmap">selforgmap</a>([8 8]);
%   net = <a href="matlab:doc train">train</a>(net,x);
%   <a href="matlab:doc view">view</a>(net)
%   y = net(x);
%   classes = vec2ind(y);
%   
% See also NPRTOOL, PATTERNNET, NCTOOL, SELFORGMAP, NNDATASETS.
%
% ----------
%
% The original data, with 15,000 ion intensity level measurements per
% patient can be obtained from the FDA-NCI Clinical Proteomics Program
% Databank: http://home.ccr.cancer.gov/ncifdaproteomics/ppatterns.asp
%
% To reformat and feature select that data to recreate this dataset, see
% the direcions in the example <a href="matlab:doc cancerdetectdemonnet">cancerdetectdemonnet</a> using Bioinformatics
% Toolbox.
%
% T.P. Conrads, et al., "High-resolution serum proteomic features for
% ovarian detection", Endocrine-Related Cancer, 11, 2004, pp. 163-178.
%
% E.F. Petricoin, et al., "Use of proteomic patterns in serum to
% identify ovarian cancer", Lancet, 359(9306), 2002, pp. 572-577.

% Copyright 2011-2012 The MathWorks, Inc.

load ovarian_dataset
inputs = ovarianInputs;
targets = ovarianTargets;
