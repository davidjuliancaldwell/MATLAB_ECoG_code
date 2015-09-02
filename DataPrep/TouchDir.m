function TouchDir(path)

slashies = find(path=='/' | path=='\');
if slashies(end) ~= length(path)
    slashies(end+1) = length(path);
end

for i=slashies
    destDir = path(1:i);
    [a b c] = mkdir(destDir);
end
