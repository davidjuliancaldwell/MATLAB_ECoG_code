function flag = nn_textcmp(text1,text2)

% Copyright 2010 The MathWorks, Inc.

numLines = length(text1);
if length(text2) ~= numLines
  flag = false;
  return
end

for i=1:numLines
  if ~strcmp(text1{i},text2{i})
    flag = false;
    return
  end
end

flag = true;
