function out = stripExtraSlashes(in)
    out = strrep(in, [filesep filesep], filesep); 
end