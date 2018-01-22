function add_temp_path
%ADD_TEMP_PATH Add temporary NNET directory to path.

%   $Revision: 1.1.8.2 $  $Date: 2011/05/09 01:04:50 $
% Copyright 1992-2011 The MathWorks, Inc.
  
%persistent done
%if isempty(done)
    nntempdir=fullfile(tempdir,'matlab_nnet');
    if ~exist(nntempdir,'dir')
        mkdir(tempdir,'matlab_nnet')
    end
    if isempty(strfind(path,nntempdir))
        path(path,nntempdir);
    end
%    done=1;
%end
