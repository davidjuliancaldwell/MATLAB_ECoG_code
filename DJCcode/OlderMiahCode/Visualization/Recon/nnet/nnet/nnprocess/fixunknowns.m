function [y,settings] = fixunknowns(x,varargin)
%FIXUNKNOWNS Processes matrix rows with unknown values.
%
% <a href="matlab:doc fixunknowns">fixunknowns</a> should only be used to process inputs, not outputs or
% targets.
%	
%	<a href="matlab:doc fixunknowns">fixunknowns</a> processes data by replacing each row containing
% unknown values (represented by NaN) with two rows. The first row contains
% the original row, with NaN values replaced by the row's mean.  The second
% row contains 1 and 0 values, indicating which values in the first row
% were known or unknown, respectively. Using FIXUNKNOWNS as an input
% processing function allows a network to use data with unknowns, and
% even perhaps use the existence of unknowns as useful information.
%
% [Y,settings] = <a href="matlab:doc fixunknowns">fixunknowns</a>(X) takes matrix or cell array neural network
% input data, transforms it, and returns the result and the settings used
% to perform the transform.
%
% Here some data with unknowns is processed into more usable form:
%
%   x1 = [1 2 3 4; 4 NaN 6 5; NaN 2 3 NaN]
%   [y1,settings] = <a href="matlab:doc fixunknowns">fixunknowns</a>(x1)
%
% <a href="matlab:doc fixunknowns">fixunknowns</a>('apply',X,settings) transforms X consistent with settings
% returned by a previous transformation.
%
%   x2 = [4 5 3 2; NaN 9 NaN 2; 4 9 5 2]
%   y2 = <a href="matlab:doc fixunknowns">fixunknowns</a>('apply',x2,settings)
%
% <a href="matlab:doc fixunknowns">fixunknowns</a>('reverse',Y,settings) reverse transforms Y consistent with
% settings returned by a previous transformation.
%
%   x1_again = <a href="matlab:doc fixunknowns">fixunknowns</a>('reverse',y1,settings)
%
%  See also MAPMINMAX, MAPSTD, PROCESSPCA, REMOVECONSTANTROWS.

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
[y,settings] = fixunknowns.create(x,param);
