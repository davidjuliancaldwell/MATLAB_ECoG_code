function text = load(path)

% Copyright 2010-2011 The MathWorks, Inc.

% Multiple Files
if iscell(path)
  n = numel(path);
  text = cell(size(path));
  for i=1:n
    text{i} = nntext.load(path{i});
  end
  return
end

% Single File
file = fopen(path,'r');
if (file == -1)
  nnerr.throw(['Cannot open file: ' path]);
end
text = {};
while true
  line = fgetl(file);
  if ~ischar(line), break; end
  text = [text; {line}];
end
fclose(file);
