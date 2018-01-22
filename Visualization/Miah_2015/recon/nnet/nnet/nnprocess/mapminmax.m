function [y,settings] = mapminmax(x,varargin)
%MAPMINMAX Map matrix row minimum and maximum values to [-1 1].
% 
% <a href="matlab:doc mapminmax">mapminmax</a> processes input and target data by mapping it from its original
% range to the range [-1 1].
%
% [Y,settings] = <a href="matlab:doc mapminmax">mapminmax</a>(X) takes matrix or cell array neural data,
% returns it transformed with the settings used to perform the transform.
%
% Here random data with non-standard ranges in each row is transformed.
%
%   x1 = [rand(1,20)*5-1; rand(1,20)*20-10; rand(1,20)-1];
%   [y1,settings] = <a href="matlab:doc mapminmax">mapminmax</a>(x1)
%
% <a href="matlab:doc mapminmax">mapminmax</a>.apply(X,settings) transforms X consistent with settings
% returned by a previous transformation.
%
%   x2 = [rand(1,20)*5-1; rand(1,20)*20-10; rand(1,20)-1];
%   y2 = <a href="matlab:doc mapminmax">mapminmax</a>.apply(x2,settings)
%
% <a href="matlab:doc mapminmax">mapminmax</a>.reverse(Y,settings) reverse transforms Y consistent with
% settings returned by a previous transformation.
%
%   x1_again = <a href="matlab:doc mapminmax">mapminmax</a>.reverse(y1,settings)
%
% See also MAPSTD, PROCESSPCA, REMOVECONSTANTROWS.

% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.6.16 $

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
if (nargin == 3) && isnumeric(varargin{1}) && isnumeric(varargin{2})
  param.ymin = varargin{1};
  param.ymax = varargin{2};
end
[y,settings] = mapminmax.create(x,param);
