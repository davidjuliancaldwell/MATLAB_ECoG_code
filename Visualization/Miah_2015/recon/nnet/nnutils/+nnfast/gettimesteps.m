function varargout = gettimesteps(varargin)
%GETTIMESTEPS_FAST (NNSTRICTDATA,IND)

% Copyright 2010 The MathWorks, Inc.

numData = nargin-1;
ind = varargin{end};
varargout = cell(1,numData);
for i = 1:numData
  varargout{i} = varargin{i}(:,ind);
end
