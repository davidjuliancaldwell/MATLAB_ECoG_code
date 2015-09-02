function [inputs,targets] = wine_dataset
%WINE_DATASET Italian wines dataset
%
% Pattern recognition is the process of training a neural network to assign
% the correct target classes to a set of input patterns.  Once trained the
% network can be used to classify patterns it has not seen before.
%
% This dataset can be used to create a neural network that classifies
% wines from three winerys in Italy based on constituents found through
% chemical analysis.
% 
% LOAD <a href="matlab:doc wine_dataset">wine_dataset</a>.MAT loads these two variables:
%
%   wineInputs - a 13x178 matrix of thirteen attributes of 178 wines.
%
%     1. Alcohol
%     2. Malic acid
%     3. Ash
%     4. Alcalinity of ash  
%     5. Magnesium
%     6. Total phenols
%     7. Flavanoids
%     8. Nonflavanoid phenols
%     9. Proanthocyanins
%    10. Color intensity
%    11. Hue
%    12. OD280/OD315 of diluted wines
%    13. Proline
%
%   wineTargets - a 3x178 matrix of 7200 associated class vectors
%   defining which of three classes each input is assigned to.  Classes
%   are represented by a 1 in row 1, 2 or 3.
%
%     1. Vinyard #1
%     2. Vinyard #2
%     3. Vinyard #3
%
% [X,T] = <a href="matlab:doc wine_dataset">wine_dataset</a> loads the inputs and targets into
% variables of your own choosing.
%
% For an intro to pattern recognition with the <a href="matlab:nprtool">NN Pattern Recognition Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a pattern recognition neural network with this
% data at the command line.  See <a href="matlab:doc patternnet">patternnet</a> for more details.
%
%   [x,t] = <a href="matlab:doc wine_dataset">wine_dataset</a>;
%   net = <a href="matlab:doc patternnet">patternnet</a>(10);
%   net = <a href="matlab:doc train">train</a>(net,x,t);
%   <a href="matlab:doc view">view</a>(net)
%   y = net(x);
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
% Donated to the repository by Stefan Aeberhard.

% Copyright 2010 The MathWorks, Inc.

load wine_dataset
inputs = wineInputs;
targets = wineTargets;
