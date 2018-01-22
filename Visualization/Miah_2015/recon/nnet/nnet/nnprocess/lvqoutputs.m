function [y,settings] = lvqoutputs(x,varargin)
%LVQOUTPUTS Define settings for LVQ outputs, without changing values.
%
% <a href="matlab:doc lvqoutputs">lvqoutputs</a> is only intended to be used as an output processing function
% by LVQ networks.
%
% [Y,settings] = <a href="matlab:doc lvqoutputs">lvqoutputs</a>(X) takes matrix or cell array neural network
% data and returns it unchanged, but stores class ratio information
% in the settings, useful for initializing weights to LVQ network output
% layers.
%
% Here some 1-of-N data X1 is defined, representing 1000 samples of
% categorizations into one of four classes.  <a href="matlab:doc lvqoutputs">lvqoutputs</a> will record
% the prevalence of each of the four classes in this data.
%
%   x1 = compet(rand(4,1000));
%   [y1,settings] = <a href="matlab:doc lvqoutputs">lvqoutputs</a>(x1)
%
% <a href="matlab:doc lvqoutputs">lvqoutputs</a>('apply',X,settings) returns X unchanged.
% <a href="matlab:doc lvqoutputs">lvqoutputs</a>('reverse',Y,settings) returns Y unchanged.
%
%  See also LVQNET.

% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.10.6 $

% Function Info
if nargin == 0
  y = nn_processing_fcn.info(mfilename); return
end
  
% Backward Compatibility
if ischar(x)
  if nargout < 2
    y = nnet7.process_fcn(mfilename,x,varargin{:});
  else
    [y,settings] = nnet7.process_fcn(mfilename,x,varargin{:});
  end
  return
end
  
% Create
param = nn_modular_fcn.getParamStructFromArgs(mfilename,varargin);
[y,settings] = lvqoutputs.create(x,param);

