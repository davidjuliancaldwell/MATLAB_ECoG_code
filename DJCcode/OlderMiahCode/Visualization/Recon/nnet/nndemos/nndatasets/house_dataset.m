function [inputs,targets] = house_dataset
%HOUSE_DATASET House value dataset
%
% Function fitting is the process of training a neural network on a
% set of inputs in order to produce an associated set of target outputs.
% Once the neural network has fit the data, it forms a generalization of
% the input-output relationship and can be used to generate outputs for
% inputs it was not trained on.
%
% This dataset can be used to train a neural network to estimate the
% median house price in a neighborhood based on neighborhood statistics.
%
% LOAD <a href="matlab:doc house_dataset">house_dataset</a>.MAT loads these two variables:
%
%   houseInputs - a 13x506 matrix defining thirteen attributes of 506
%   different neighborhoods.
%
%     1. Per capita crime rate per town
%     2. Proportion of residential land zoned for lots over 25,000 sq. ft.
%     3. proportion of non-retail business acres per town
%     4. 1 if tract bounds Charles river, 0 otherwise
%     5. Nitric oxides concentration (parts per 10 million)
%     6. Average number of rooms per dwelling
%     7. Proportion of owner-occupied units built prior to 1940
%     8. Weighted distances to five Boston employment centres
%     9. Index of accessibility to radial highways
%    10. Full-value property-tax rate per $10,000
%    11. Pupil-teacher ratio by town
%    12. 1000(Bk - 0.63)^2, where Bk is the proportion of blacks by town
%    13. Percent lower status of the population
%
%   houseTargets - a 1x506 matrix of median values of owner-occupied homes
%   in each neighborhood in 1000's of dollars.
%
% [X,T] = <a href="matlab:doc house_dataset">house_dataset</a> loads the inputs and targets into
% variables of your own choosing.
%
% For an intro to fitting with the <a href="matlab:nftool">NN Fitting Tool</a>
% click "Load Example Data Set" in the second panel and pick this dataset.
%
% Here is how to design a fitting neural network with 10 hidden neurons
% with this data at the command line.  See <a href="matlab:doc fitnet">fitnet</a> for more details.
%
%   [x,t] = <a href="matlab:doc house_dataset">house_dataset</a>;
%   net = <a href="matlab:doc fitnet">fitnet</a>(10);
%   net = <a href="matlab:doc train">train</a>(net,x,t);
%   <a href="matlab:doc view">view</a>(net)
%   y = net(x);
%
% See also NFTOOL, NEWFIT, NNDATASETS.
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
% This dataset originated from the StatLib library which is maintained at
% Carnegie Mellon University.

% Copyright 2010 The MathWorks, Inc.

load house_dataset
inputs = houseInputs;
targets = houseTargets;
