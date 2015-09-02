function id = extractSubjid(pathname)

    subdir = [stripTrailingSlash(stripExtraSlashes(myGetenv('subject_dir'))) filesep];
    pathname = stripExtraSlashes(pathname);
    
    if (strcmp(filesep, '\')) % on the windows OS, filesep is the escape character
        pathname = strrep(pathname, filesep, '/');
        subdir = strrep(subdir, filesep, '/');
    end
    
    id = regexpi(pathname, [subdir '([a-zA-Z0-9]+)'], 'once', 'tokens');
%     pathname = strrep(pathname, '\\', '\');
%     id = regexpi(pathname, [strrep(myGetenv('subject_dir'), '\', '\\') '([a-zA-Z0-9]+)'], 'once', 'tokens');
    
    if (isempty(id))
        warning ('no subject id found');
    else
        id = id{1};    
    end
end