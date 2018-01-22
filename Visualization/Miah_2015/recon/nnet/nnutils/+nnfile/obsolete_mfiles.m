function mfiles = obsolete_mfiles

% Copyright 2010 The MathWorks, Inc.

parentdirs = fullfile(nnpath.nnet_root,'toolbox','nnet','nnobsolete');
mfiles = nnfile.mfiles(parentdirs,'all');
