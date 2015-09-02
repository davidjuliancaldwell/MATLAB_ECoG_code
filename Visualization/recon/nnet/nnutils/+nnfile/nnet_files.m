function files = nnet_files(root)
%NN_NNET_FILES All NNET files.

% Copyright 2010 The MathWorks, Inc.

if nargin < 1, root = nnpath.nnet_root; end

files = nn_all_files(nn_nnet_top_paths(root));
