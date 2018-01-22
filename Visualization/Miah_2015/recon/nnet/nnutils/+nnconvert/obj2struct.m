function s = obj2struct(x)

% Copyright 2010 The MathWorks, Inc.

if iscell(x)
  s = cell(size(x));
  for i=1:numel(x)
    s{i} = nnconvert.obj2struct(x{i});
  end
  return;
end

if ~isobject(x)
  s = x;
  return
end

s = struct;
fn = fieldnames(x);
for i=1:length(fn)
  fni = fn{i};
  v1 = x.(fni);
  if strcmp(fni,'gradientFcn') || strcmp(fni,'gradientParam')
    % NNET 6.0 Compatibility
    v2 = v1;
  elseif isstruct(v1) || isobject(v1) || iscell(v1)
    v2 = nnconvert.obj2struct(v1);
  else
    v2 = v1;
  end
  s.(fni) = v2;
end
