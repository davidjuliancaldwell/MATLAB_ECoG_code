function flag = nn_is_binary_ext(ext)

% Copyright 2010-2011 The MathWorks, Inc.

flag = ~isempty(nnstring.first_match(ext,{'mat','png','enc'}));
