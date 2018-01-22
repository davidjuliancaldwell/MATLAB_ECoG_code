function files=nnet_toolbox_files(root,paths)

% Copyright 2010-2012 The MathWorks, Inc.

if nargin < 1, root = nnpath.nnet_root; end

files = nnfile.files(fullfile(root,'toolbox','nnet'),'all');
