function list = listDatFiles(subjid, matchStr)
    datadir = fullfile(getSubjDir(subjid));    
    list = rdir(datadir, @(str)(strendswith(str, '.dat') && ~isempty(strfind(str, matchStr))));
end

