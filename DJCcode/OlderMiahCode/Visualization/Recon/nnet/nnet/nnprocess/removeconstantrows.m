function [y,settings] = removeconstantrows(x,varargin)
%REMOVECONSTANTROWS Remove matrix rows with constant values.
%	
% <a href="matlab:doc removeconstantrows">removeconstantrows</a> processes input and target data by removing rows
% with constant values. Constant values do not provide a network with any
% information and can cause numerical problems for some algorithms.
%
% [Y,settings] = <a href="matlab:doc removeconstantrows">removeconstantrows</a>(X) takes matrix or cell array data,
% returns it transformed with the settings used to perform the transform.
%
% Here is data with whose second row is constant.
%
%   x1 = [rand(1,20)*5-1; ones(1,20)+6; rand(1,20)-1];
%   [y1,settings] = <a href="matlab:doc removeconstantrows">removeconstantrows</a>(x1)
%
% <a href="matlab:doc removeconstantrows">removeconstantrows</a>('apply',X,settings) transforms X consistent with
% settings returned by a previous transformation.
%
%   x2 = [rand(1,20)*5-1; ones(1,20)+6; rand(1,20)-1];
%   y2 = <a href="matlab:doc removeconstantrows">removeconstantrows</a>('apply',x2,settings)
%
% <a href="matlab:doc removeconstantrows">removeconstantrows</a>('reverse',Y,settings) reverse transforms Y consistent
% with settings returned by a previous transformation.
%
%   x1_again = <a href="matlab:doc removeconstantrows">removeconstantrows</a>('reverse',y1,settings)
%
% See also REMOVEROWS, FIXUNKNOWNS.

% Copyright 1992-2012 The MathWorks, Inc.

% Mark Hudson Beale, 4-16-2002, Created

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
[y,settings] = removeconstantrows.create(x,param);

