function message1 = value(message1,varargin)
%NNREPVAL Replaces 'VALUE' with variable name in message string.
%
%  NNREPVAL(MESSAGE,NAME) updates MESSAGE by replacing an occurrance
%  of 'VALUE' with the string NAME.
%
%  NNREPVAL(MESSAGE,NAME1,NAME2,...) updates MESSAGE by replacing
%  occurrances of 'VALUE1', 'VALUE2', etc., with strings NAME1, NAME2, etc.
%
%  NNREPVAL(MESSAGE,{NAME1,NAME2,...}) is an alternate calling
%  form to NNREPVAL(MESSAGE,NAME,NAME2,...)

% Copyright 2010-2011 The MathWorks, Inc.

if nargin == 1, return; end

% Alternate calling form
names = varargin;
if (length(names)==1) && iscell(names{1})
  names = names{1};  
end
numNames = length(varargin);

% Fill in value names in message
if numNames == 1
  name = names{1};
  message1 = strrep(message1,'VALUE',name);
elseif numNames > 1
  for i=1:numNames
    message1 = strrep(message1,['VALUE' num2str(i)],names{i});
  end
end
