function s = nn_num2str(b)

% Copyright 2010 The MathWorks, Inc.

if isempty(b)
  s = '[]';
elseif numel(b) == 1
  s = num2str(b);
else
  s = sprintf(['[%gx%g ' class(b) ']'],size(b,1),size(b,2));
end
