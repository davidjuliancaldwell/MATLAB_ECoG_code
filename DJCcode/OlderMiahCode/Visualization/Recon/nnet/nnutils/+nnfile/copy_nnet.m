function nn_copy_nnet(from,to)

% Copyright 2010 The MathWorks, Inc.

if nargin < 2, error(message('nnet:Args:NotEnough')); end

files1 = nn_nnet_files(from);
files2 = nn_rel2abs_files(nn_abs2rel_files(files1,from),to);
nn_copy_files(files1,files2);
