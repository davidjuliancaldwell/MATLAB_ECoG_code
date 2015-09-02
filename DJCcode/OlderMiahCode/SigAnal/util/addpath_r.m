function addpath_r(basedir)
    if (isdir(basedir) == false)
        error('%s is not a directory \n', basedir);
        return;
    end
    
    addpath(basedir);
%     fprintf('would add %s\n', basedir);
    
    files = dir(basedir);
    
    for c = 1:length(files)
        temp = files(c).name;
        if (strcmp(temp, '.') == 0 && strcmp(temp, '..') == 0 && strcmp(temp, '.svn') == 0 && isdir([basedir '\' temp]))
            addpath_r([basedir '\' temp]);
        end
    end
    
end