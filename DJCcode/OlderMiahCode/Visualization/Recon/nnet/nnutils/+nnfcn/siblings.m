function mfunctions = siblings(mfunction)

% Copyright 2010-2012 The MathWorks, Inc.

% Find function
filePath = which(mfunction);

% Find all .m files in same folder
path = fileparts(filePath);
files = nnfile.mfiles(path);
mfunctions = nnpath.file2fcn(files);

% Remove Contents file
for i=length(mfunctions):-1:1
  if nnstring.ends(mfunctions{i},'Contents')
    mfunctions(i) = [];
  end
end
