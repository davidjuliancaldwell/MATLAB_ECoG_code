function out = stripTrailingSlash(in)
    if (strendswith(in, filesep))
        out = in(1:(end-length(filesep)));
    else
        out = in;
    end
end