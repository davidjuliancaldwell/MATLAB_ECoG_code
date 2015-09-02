function keeperpaths = rdir(startdir, keeperfunc)
    keeperpaths = {};
    keeperpaths = sub_rdir(startdir, keeperpaths, keeperfunc);
end

function keeperpaths = sub_rdir(startdir, keeperpaths, keeperfunc)
    testfiles = dir(startdir);
    
    for testfile = testfiles'       
        if (strcmp(testfile.name, '.') || strcmp(testfile.name, '..'))
            % no op
        elseif (testfile.isdir)
            keeperpaths = sub_rdir(fullfile(startdir, testfile.name), keeperpaths, keeperfunc);
        elseif (keeperfunc(testfile.name))
            keeperpaths{end+1} = fullfile(startdir, testfile.name);
        end
    end
end
