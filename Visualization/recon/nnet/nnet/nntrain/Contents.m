% Neural Network Toolbox Training Functions.
%
% To change a neural network's training algorithm set the net.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a>
% property to the name of the corresponding function.  For example, to use
% the scaled conjugate gradient backprop training algorithm:
%
%   net.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> = '<a href="matlab:doc trainscg">trainscg</a>';
%
% Backpropagation training functions that use Jacobian derivatives
%
%   These algorithms can be faster but require more memory than gradient
%   backpropation.  They are also not supported on GPU hardware.
%
%   trainlm   - Levenberg-Marquardt backpropagation.
%   trainbr   - Bayesian Regulation backpropagation.
%
% Backpropagation training functions that use gradient derivatives
%
%   These algorithms may not be as fast as Jacobian backpropagation.
%   They are supported on GPU hardware with the Parallel Computing Toolbox.
%
%   trainbfg  - BFGS quasi-Newton backpropagation.
%   traincgb  - Conjugate gradient backpropagation with Powell-Beale restarts.
%   traincgf  - Conjugate gradient backpropagation with Fletcher-Reeves updates.
%   traincgp  - Conjugate gradient backpropagation with Polak-Ribiere updates.
%   traingd   - Gradient descent backpropagation.
%   traingda  - Gradient descent with adaptive lr backpropagation.
%   traingdm  - Gradient descent with momentum.
%   traingdx  - Gradient descent w/momentum & adaptive lr backpropagation.
%   trainoss  - One step secant backpropagation.
%   trainrp   - RPROP backpropagation.
%   trainscg  - Scaled conjugate gradient backpropagation.
%
% Supervised weight/bias training functions
%
%   trainb    - Batch training with weight & bias learning rules.
%   trainc    - Cyclical order weight/bias training.
%   trainr    - Random order weight/bias training.
%   trains    - Sequential order weight/bias training.
%
% Unsupervised weight/bias training functions
%
%   trainbu   - Unsupervised batch training with weight & bias learning rules.
%   trainru   - Unsupervised random order weight/bias training.
%
% <a href="matlab:help nnet/Contents.m">Main nnet function list</a>.
 
% Copyright 1992-2012 The MathWorks, Inc.
