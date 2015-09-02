function y = catsignals(varargin)
%CATSIGNALS_FAST (STRICTNNDATA,STRICTNNDATA,...)

% Copyright 2010 The MathWorks, Inc.

if nargin == 0
  y = {};
  return
end

if nargin == 1
  y = varargin{1};
  return
end

y = cat(1,varargin{:});
