function flag = nnequal(a,b)
%EQUAL

% Copyright 2010 The MathWorks, Inc.

if ~isa(a,class(b))
  flag = nnfail; return;
end
if iscell(a)
  flag = nnequal_cell(a,b);
elseif isstruct(a)
  flag = nnequal_struct(a,b);
elseif isobject(a)
  flag = nnequal_struct(struct(a),struct(b));
else
  flag = nnequal_matrix(a,b);
end

function flag = nnequal_matrix(a,b)
sa = size(a);
sb = size(b);
if (length(sa)==length(sb)) && all(sa==sb)
  flag = true;
else
  flag = nnfail;
end

function flag = nnequal_cell(a,b)
if ~nnequal_matrix(size(a),size(b))
  flag = nnfail; return;
end
for i=1:numel(a)
  if ~nnequal(a{i},b{i})
    flag = nnfail; return;
  end
end
flag = true;

function flag = nnequal_struct(a,b)
fa = fieldnames(a);
fb = fieldnames(b);
if ~nnequal(fa,fb)
  flag = nnfail; return;
end
for i=1:numel(fa)
  fn = fa{i};
  if strcmp(fn,'name'), continue, end
  if ~nnequal(a.(fn),b.(fn))
    flag = false; nnfail; return;
  end
end
flag = true;

function flag = nnfail
flag = false;
