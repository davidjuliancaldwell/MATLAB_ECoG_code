function [elts, file, ext] = pathelements (path)
    elts = {};
     
    while true
        [str, path] = strtok(path, filesep);
        
        if (isempty(path))
            [~, file, ext] = fileparts(str);
            break;
        else
            elts{end+1} = str;
        end
    end
end