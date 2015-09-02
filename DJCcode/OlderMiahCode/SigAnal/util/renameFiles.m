function renameFiles (startdir, oldstr, newstr)
    files = dir(startdir);
    
    for idx = 1:length(files)
        fname = files(idx).name;
        fpath = [startdir '\' files(idx).name];
        
        if(isdir(fpath))
            if (strcmp(fname, '.') == 0 && strcmp(fname, '..') == 0)
                renameFiles(fpath, oldstr, newstr);
            end
        end
        
        if (strfind(fname, oldstr))
            oldname = fpath;
            newname = [startdir '\' strrep(fname, oldstr, newstr)];
            fprintf('rename %s to %s\n', oldname, newname);
            movefile(oldname, newname);
        end
    end
end
