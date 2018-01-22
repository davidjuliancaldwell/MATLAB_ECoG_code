function str = message_link(message1,filename)
%NN_WARNING_LINK Message string with link to warning doc file.
%
%  STR = NN_MESSAGE_LINK(message,warning_filename)

% Copyright 2010 The MathWorks, Inc.

str = nnlink.str2link(message1,['matlab:doc ' filename]);
