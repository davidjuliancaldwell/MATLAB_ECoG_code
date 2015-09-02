function [inputs,targets] = cancer_dataset
%CANCER_DATASET Breast cancer dataset
%
% Pattern recognition is the process of training a neural network to assign
% the correct target classes to a set of input patterns.  Once trained the
% network can be used to classify patterns it has not seen before.
%
% This dataset can be used to design a neural network that classifies
% cancers as either benign or malignant depending on the characteristics
% of sample biopsies.
%
% LOAD <a href="matlab:doc cancer_dataset">cancer_dataset</a>.MAT loads these two variables:
%
%   cancerInputs - a 9x699 matrix defining nine attributes of 699 biopsies.
%
%     1. Clump thickness
%     2. Uniformity of cell size
%     3. Uniformity of cell shape
%     4. Marginal Adhesion
%     5. Single epithelial cell size
%     6. Bare nuclei
%     7. Bland chomatin
%     8. Normal nucleoli
%     9. Mitoses
%
%   cancerTargets - a 2x966 matrix where each column indicates a correct
%   category with a one in either element 1 or element 2.
%
%     1. Benign
%     2. Malignant
%
% [X,T] = <a href="matlab:doc cancer_dataset">cancer_dataset</a> loads the inputs and targets into
% variables of your own choosing.
%
% For an intro to pattern recognition with the <a href="matlab:nprtool">NN Pattern Recognition Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a pattern recognition neural network with this
% data at the command line.  See <a href="matlab:doc patternnet">patternnet</a> for more details.
%
%   [x,t] = <a href="matlab:doc cancer_dataset">cancer_dataset</a>;
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
%   x = <a href="matlab:doc simplecluster_dataset">simplecluster_dataset</a>;
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
% This data is available from the UCI Machine Learning Repository.
%
%   http://mlearn.ics.uci.edu/MLRepository.html
%
% Murphy,P.M., Aha, D.W. (1994). UCI Repository of machine learning
% databases [http://www.ics.uci.edu/~mlearn/MLRepository.html].
% Irvine, CA: University of California,  Department of Information
% and Computer Science.
%
% Donated by Olvi Mangasarian.

% Copyright 2010 The MathWorks, Inc.

load cancer_dataset
inputs = cancerInputs;
targets = cancerTargets;
