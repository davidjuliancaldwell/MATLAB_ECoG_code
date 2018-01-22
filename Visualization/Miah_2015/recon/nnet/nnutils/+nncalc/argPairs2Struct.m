function s = nameValuePairsOverrideStruct(s,pairs)

% Copyright 2012 The MathWorks, Inc.

numPairs = numel(pairs)/2;
if rem(numPairs,1) ~= 0
  error('nnet:OddNumberOfNameValues','Odd number of name/value pair arguments.');
end

names = pairs(1:2:numel(pairs));
values = pairs(2:2:numel(pairs));

fields = fieldnames(s);
fields_lower = lower(fields);

for i=1:length(names)
  n = names{i};
  v = values{i};
  
  if ~ischar(n) || (ndims(n)>2) || (size(n,1)~=1)
    error('nnet:NotALegalParameterName','Argument is not a legal parameter name.');
  end
  j = nnstring.match(lower(n),fields_lower);
  if isempty(j)
    error('nnet:NotALegalParameter',['Not a legal parameter: ' n]);
  end
  
  s.(fields{j}) = v;
end
