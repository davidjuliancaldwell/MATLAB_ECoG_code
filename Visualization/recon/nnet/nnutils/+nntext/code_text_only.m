function text = nn_codetextonly(text)

% Copyright 2010 The MathWorks, Inc.

numLines = length(text);
keep = false(1,numLines);
for i=1:numLines
  line = text{i};
  line = nn_remove_str_whitespace(line);
  text{i} = line;
  keep(i) = ~isempty(line);
end
text = text(keep);
