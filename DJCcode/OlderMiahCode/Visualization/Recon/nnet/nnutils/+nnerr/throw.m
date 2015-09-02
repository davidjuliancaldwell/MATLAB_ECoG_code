function throw(tag,message1,varargin)
%NNERR Throws nnet error in calling function, with update message.
%
%  NNERR(TAG,MESSAGE) throws the error ('nnet:FILENAME:TYPE',message)
%  in the calling function, where FILENAME is the name of the calling
%  function.
%
%  NNERR(TYPE,MESSAGE,NAME) updates message by replacing an occurrance
%  of 'VALUE' with the string NAME before throwing the error.
%
%  NNERR(TYPE,MESSAGE,NAME1,NAME2,...) updates message by replacing
%  occurrances of 'VALUE1', 'VALUE2', etc., with strings NAME1, NAME2, etc.
%
%  NNERR(TYPE,MESSAGE,{NAME1,NAME2,...}) is an alternate calling
%  form to NERR(TYPE,MESSAGE,NAME,NAME2,...)

% Copyright 2010-2011 The MathWorks, Inc.

if nargin == 1
  message1 = tag;
  tag = 'Arguments';
end

% Alternate calling forms
names = varargin;
if (length(names)==1) && iscell(names{1})
  names = names{1};  
end

% Fill in value names in message
if isempty(names)
  message1 = nnerr.value(message1,'Value');
else
  message1 = nnerr.value(message1,names);
end

% Thow error in calling function
throwAsCaller(MException(nnerr.tag(tag,2),message1));
