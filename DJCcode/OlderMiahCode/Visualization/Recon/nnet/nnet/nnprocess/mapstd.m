function [y,settings] = mapstd(x,varargin)
%MAPSTD Map matrix row means and deviations to standard values.
%  
% <a href="matlab:doc mapstd">mapstd</a> processes input and target data by mapping its mean and
% standard deviations to 0 and 1 respectively.
%
% [Y,settings] = <a href="matlab:doc mapstd">mapstd</a>(X) takes matrix or cell array neural data,
% returns it transformed with the settings used to perform the transform.
%
% Here data with non-standard mean/deviations in each row is transformed.
%
%   x1 = [log(rand(1,20)*5-1); rand(1,20)*20-10; rand(1,20)-1];
%   [y1,settings] = <a href="matlab:doc mapstd">mapstd</a>(x1)
%
% <a href="matlab:doc mapstd">mapstd</a>('apply',X,settings) transforms X consistent with settings
% returned by a previous transformation.
%
%   x2 = [log(rand(1,20)*5-1); rand(1,20)*20-10; rand(1,20)-1];
%   y2 = <a href="matlab:doc mapstd">mapstd</a>('apply',x2,settings)
%
% <a href="matlab:doc mapstd">mapstd</a>('reverse',Y,settings) reverse transforms Y consistent with
% settings returned by a previous transformation.
%
%   x1_again = <a href="matlab:doc mapstd">mapstd</a>('reverse',y1,settings)
%
% See also MAPMINMAX, PROCESSPCA, REMOVECONSTANTROWS.

% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.6.17 $

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
[y,settings] = mapstd.create(x,param);

