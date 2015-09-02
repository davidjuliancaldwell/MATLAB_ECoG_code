% loads cache data, must first set the subjid 'parameter'
if (~exist('subjid', 'var'))
    error('subject id (subjid) is undefinded');
end

tmp = pwd;
cd (fileparts(which('LoadCacheData')));
load(fullfile('..', 'metadata', 'AllPower.m.cache', [subjid '.mat']));
cd (tmp);
clear tmp;