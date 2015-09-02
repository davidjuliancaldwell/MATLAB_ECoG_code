function v = nn_cellstruct_select(c,f)

% Copyright 2010 The MathWorks, Inc.

v = cell(size(c));
for j=1:numel(v)
  cj = c{j};
  if ~isempty(cj)
    v{j} = cj.(matchfield(f,cj));
  end
end

function field = matchstring(field,strings)
% MATCHFIELD replaces FIELD with any field belonging to STRUCTURE
% that is the same when case is ignored.

for i=1:length(strings)
  if strcmpi(field,strings{i})
    field = strings{i};
    return;
  end
end
field = [];

function field = matchfield(field,structure)
% MATCHFIELD replaces FIELD with any field belonging to STRUCTURE
% that is the same when case is ignored.

field = matchstring(field,fieldnames(structure));
