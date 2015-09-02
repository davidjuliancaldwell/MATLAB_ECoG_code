function [y,settings] = processpca(x,varargin)
%PROCESSPCA Processes rows of matrix with principal component analysis.
%  
% <a href="matlab:doc processpca">processpca</a> process data so that the rows become uncorrelated and are
% ordered in terms of their contribution to total variation. In addition,
% rows whose contribution is too weak may be removed.
%
% [Y,settings] = <a href="matlab:doc processpca">processpca</a>(X) takes neural data and returns it transformed
% with the settings used to make the transform.
%
% [Y,settings] = <a href="matlab:doc processpca">processpca</a>(X,'maxfrac',maxfrac) takes an optional
% parameter overriding the default fraction of variance contribution (0)
% used to determine which rows to remove.
%
% Here is data in which only two rows actually contribute information.
%
%   x1 = rand(2,20);
%   x1 = [x1; (x1(1,:)+x1(2,:))*0.5];
%   [y1,settings] = <a href="matlab:doc processpca">processpca</a>(x1,'maxfrac',0.01)
%
% <a href="matlab:doc processpca">processpca</a>('apply',X,settings) transforms X consistent with settings
% returned by a previous transformation.
%
%   x2 = rand(2,20);
%   x2 = [x2; (x2(1,:)+x2(2,:))*0.5];
%   y2 = <a href="matlab:doc processpca">processpca</a>('apply',x2,settings)
%
% <a href="matlab:doc processpca">processpca</a>('reverse',Y,settings) reverse transforms Y consistent with
% settings returned by a previous transformation.
%
%   x1_again = <a href="matlab:doc processpca">processpca</a>('reverse',y1,settings)
%
% <a href="matlab:doc processpca">processpca</a>('dy_dx',X,Y,settings) returns the transformation derivative
% of Y with respect to X.
%
% <a href="matlab:doc processpca">processpca</a>('dx_dy',X,Y,settings) returns the reverse transformation
% derivative of X with respect to Y.%
%
% See also MAPMINMAX, MAPSTD, REMOVECONSTANTROWS

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
[y,settings] = processpca.create(x,param);

