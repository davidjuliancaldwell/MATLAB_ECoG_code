function flag = nn_iscellstruct_field(c,f)

% Copyright 2010 The MathWorks, Inc.

for i=1:numel(c)
  ci = c{i};
  if isempty(ci), continue, end
  if ~(isstruct(ci) || isobject(ci)), flag = false; return; end
  if isempty(matchfield(f,ci)), flag = false; return; end
end
flag = true;

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
