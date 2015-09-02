function ext = extension(file)

% Copyright 2010 The MathWorks, Inc.

[~,~,ext] = fileparts(file);
if ~isempty(ext), ext = ext(2:end); end
