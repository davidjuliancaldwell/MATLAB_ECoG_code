function [inputs,targets] = vinyl_dataset
%VINYL_DATASET Vinyl bromide dataset
%
% The large number of samples in this dataset make it useful for testing
% neural network training and simulation with parallel computing.
%
% Function fitting is the process of training a neural network on a
% set of inputs in order to produce an associated set of target outputs.
% Once the neural network has fit the data, it forms a generalization of
% the input-output relationship and can be used to generate outputs for
% inputs it was not trained on.
%
% This dataset can be used to train a neural network to estimate the
% MP4 energy of different chemical configurations of vinyl bromide.
%
% <a href="matlab:doc house_dataset">house_dataset</a>.mat contains these two variables:
%
%   vinylInputs - a 16x68308 matrix defining sixteen attributes of 68,308
%   different chemical configurations of vinyl bomide.
%
%     1-15. 15 bond distances defining the geometry of the chemical configuration
%     16. HF energy for the chemical configuration
%
%   vinylTargets - a 1x68308 matrix of each configuration's MP4 energy.
%
% [X,T] = <a href="matlab:doc vinyl_dataset">vinyl_dataset </a> loads the inputs and targets into
% variables of your own choosing.
%
% Here is how to design a fitting neural network with 10 hidden neurons
% with this data at the command line.  See <a href="matlab:doc fitnet">fitnet</a> for more details.
%
%   [x,t] = <a href="matlab:doc vinyl_dataset">vinyl_dataset</a>;
%   net = <a href="matlab:doc fitnet">fitnet</a>(10);
%   net2 = <a href="matlab:doc train">train</a>(net,x,t);
%   <a href="matlab:doc network/view">view</a>(net)
%   y = net2(x);
%
% The following parallel computing examples require the Parallel Computing
% Toolbox.  The same examples will run on a cluster of computers with the
% MATLAB Distributed Computing Server.
%
% To open a MATLAB pool of workers for parallel training:
%
%   matlabpool open
%   numWorkers = <a href="matlab:doc matlabpool">matlabpool</a>('size')
%   net2 = <a href="matlab:doc train">train</a>(net,x,t,'useParallel','yes','showResources','yes');
%   y = net2(x,'useParallel','yes','showResources','yes');
%
% To train with a supported GPU, using Parallel Computing Toolbox, only
% gradient training functions such as <a href="matlab:doc trainscg">trainscg</a> are supported.
%
%   gpuInfo = <a href="matlab:doc gpuDevice">gpuDevice</a>
%   net.trainFcn = '<a href="matlab:doc trainscg">trainscg</a>';
%   net2 = <a href="matlab:doc train">train</a>(net,x,t,'useGPU','yes','showResources','yes');
%   y = net2(x,'useGPU','yes','showResources','yes');
%
% To train with multiple GPUs and/or CPUs:
%
%   gpuCount = <a href="matlab:doc gpuDeviceCount">gpuDeviceCount</a>
%   net2 = <a href="matlab:doc train">train</a>(net,x,t,'useParallel','yes','useGPU','yes','showResources','yes');
%   y = net2(x,'useParallel','yes','useGPU','yes','showResources','yes');
%
% To train only with multiple GPUs (which may run faster if CPU workers
% cannot keep up with GPU workers).
%
%   net2 = <a href="matlab:doc train">train</a>(net,x,t,'useParallel','yes','useGPU','only','showResources','yes');
%   y = net2(x,'useParallel','yes','useGPU','only','showResources','yes');
%
% All the calls above with 'useParallel' set to 'yes' may be run across a cluster of
% computers using the MATLAB Distributed Computing Toolbox.
%
% See also NFTOOL, NEWFIT, NNDATASETS.
%
% ----------
%
% M. Malshe, L. M. Raff, M. G. Rockley, M. Hagan, Paras M. Agrawal,
% and R. Komanduri, ?Theoretical investigation of the dissociation dynamics
% of vibrationally excited vinyl bromide on an ab initio potential-energy
% surface obtained using modified novelty sampling and feedforward neural
% networks. II. Numerical application of the method,? The Journal of
% Chemical Physics 127, 134105, 2007.

% Copyright 2010 The MathWorks, Inc.

load vinyl_dataset
inputs = vinylInputs;
targets = vinylTargets;
